# Case Técnico — Analytics Engineering

## Contexto

A Arco Educação é um dos maiores ecossistemas de educação do Brasil, fornecendo materiais didáticos, soluções digitais e serviços de apoio pedagógico para milhares de escolas em todo o país. A operação da Arco envolve diversas marcas (isaac, COC, SAE, PGS, NSE, entre outras) e um ciclo comercial que vai desde a prospecção de escolas até a entrega de materiais e o suporte pós-venda.

O time de dados da Arco é responsável por construir e manter a camada analítica que permite ao negócio acompanhar esse ciclo de ponta a ponta: **escola → contrato → pedido → entrega → atendimento**.

## Os dados

Temos no banco analítico dados brutos de **cinco sistemas** que fazem parte do dia a dia da operação:

| Sistema | Responsabilidade | O que contém |
|---|---|---|
| **CRM** | Equipe comercial | Cadastro de escolas, usuários internos, contratos de venda, catálogo de produtos |
| **ERP A** | Operacional — marca principal | Pedidos, itens, entregas e notas fiscais (fluxo completo) |
| **ERP B** | Operacional — marca legado | Pedidos e itens (sem entrega — usa sistema financeiro externo) |
| **Sistema Financeiro** | Faturamento/logística do ERP B | Notas fiscais e status de entrega dos pedidos do ERP B |
| **Sistema de Atendimento** | Pós-venda | Cadastro próprio de escolas e usuários, tickets de suporte |


## Diagrama do ambiente raw

Os dados estão organizados em 20 tabelas, distribuídas pelos cinco sistemas:

```mermaiderDiagram
    %% ============== CRM ==============
    crm_user ||--o{ crm_account : "OwnerId"
    crm_account ||--o{ crm_service_contract : "AccountId"
    crm_service_contract ||--o{ crm_contract_line_item : "ServiceContractId"
    crm_product ||--o{ crm_contract_line_item : "ProductId"

    %% ============== ERP A ==============
    erp_a_customer ||--o{ erp_a_sales_order : "CardCode"
    erp_a_salesperson ||--o{ erp_a_sales_order : "SlpCode"
    erp_a_sales_order ||--o{ erp_a_sales_order_item : "DocEntry"
    erp_a_sales_order ||--o{ erp_a_delivery : "BaseEntry"
    erp_a_sales_order ||--o{ erp_a_invoice : "BaseEntry"

    %% ============== ERP B ==============
    erp_b_escola ||--o{ erp_b_pedido : "id_escola"
    erp_b_vendedor ||--o{ erp_b_pedido : "id_vendedor"
    erp_b_pedido ||--o{ erp_b_item_pedido : "id_pedido"

    %% ============== Financeiro ==============
    erp_b_pedido ||--o{ fin_nota_fiscal : "id_pedido_erp_b"

    %% ============== Atendimento ==============
    support_organization ||--o{ support_ticket : "organization_id"
    support_user ||--o{ support_ticket : "requester_id / assignee_id"
    support_ticket ||--o{ support_ticket_tag : "ticket_id"

    %% ============== Cross-system (pistas) ==============
    crm_account }o--o{ erp_a_customer : "CNPJ"
    crm_account }o--o{ erp_b_escola : "CNPJ"
    crm_account }o--o{ support_organization : "CNPJ"
    crm_service_contract }o--o{ erp_a_sales_order : "ContractNumber ↔ NumAtCard"
    crm_service_contract }o--o{ erp_b_pedido : "ContractNumber ↔ num_contrato"
    erp_a_sales_order }o--o{ support_ticket : "via custom_field_order_ref"
    erp_b_pedido }o--o{ support_ticket : "via custom_field_order_ref"
```

## Como explorar os dados

Pré-requisito: DuckDB 1.5.0+. A pasta `data/` já vem com `case.duckdb` pronto pra uso (`duckdb case.duckdb`), ou o banco pode ser regerado a partir dos CSVs com `duckdb case.duckdb -c ".read load.sql"`. O `load.sql` carrega as 20 tabelas e imprime a contagem de linhas de cada uma, para conferência do setup — os totais vão de dezenas de linhas (tabelas de dimensão, como `crm_user` ou `erp_b_vendedor`) a alguns milhares (tabelas de fato, como `erp_a_sales_order_item` ou `support_ticket_tag`).

Qualquer ferramenta que conecte a DuckDB pode ser usada pra explorar — SQL puro, Python, notebooks, GUIs como DBeaver (guia opcional incluso no pacote, `guia-dbeaver.md`).


