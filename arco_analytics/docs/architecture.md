# Arquitetura Medallion: Fluxo de Dados (Arco Educação)

Este documento descreve a topologia arquitetural implementada no Data Warehouse utilizando dbt e DuckDB.

## 1. Topologia (DAG Macro)

```mermaid
graph TD
    subgraph Bronze [Origens / Sistemas Raw]
        A1[(ERP A: SAP)]
        A2[(ERP B: Linx)]
        A3[(CRM: Salesforce)]
        A4[(Atendimento: Zendesk)]
    end

    subgraph Silver_Staging [Staging: Extração & Hash PII]
        S1[stg_erp_a_customer]
        S2[stg_erp_b_escola]
        S3[stg_crm_account]
        S4[stg_support_ticket]
        
        A1 --> S1
        A2 --> S2
        A3 --> S3
        A4 --> S4
    end

    subgraph Silver_Core [Core: Dimensões e Fatos Normalizadas]
        C1(dim_escolas)
        C2(dim_produtos)
        C3(fct_vendas)
        C4(fct_vendas_itens)
        C5(fct_tickets)
        
        S1 --> C1
        S2 --> C1
        S3 --> C1
        
        S1 -.-> C3
        S4 --> C5
    end

    subgraph Gold_Analytics [Gold: OBTs / Data Marts]
        G1{{obt_churn_risk_escolas}}
        G2{{obt_logistica_sla}}
        
        C1 --> G1
        C5 --> G1
        C3 --> G2
    end
```

## 2. Padrões de Design
1. **Hash de PII em Staging:** Nenhuma tabela de Core ou Gold recebe dados sensíveis puros (CNPJ, Email, Telefone). Tudo é convertido via `hash_pii` na camada Staging.
2. **Separação Header/Detail:** Pedidos (Header) e Itens (Detail) são mantidos estritamente separados em fatos distintas (`fct_vendas` e `fct_vendas_itens`) para evitar métricas falsas (Fan-out) em funções de agregação SUM().
3. **UNION ALL para Integração:** Entidades comuns (como Escolas ou Vendas) advindas de diferentes ERPs são normalizadas e aglutinadas utilizando sintaxe `UNION ALL` adicionando prefixos rígidos aos IDs (ex: `ERP_A_123`).
