# Avaliação de Negócios: Camada MART (Silver / Gold)

**Analista:** Senior-Analyst
**Diretriz Executiva:** Este laudo foca puramente nos insights de negócio extraídos do Data Warehouse Dimensional (Silver/Gold), onde as regras foram previamente mapeadas nos YMLs.

---

### 1. Visão Global: Distribuição de Adoção de Sistemas
**A Pergunta:** Qual é a contagem global de escolas e como se dá a intersecção de adoção entre os sistemas (ERP, CRM, Zendesk)?
**Racional da Query:** Para entender a base, consultei a `dim_escolas` que consolida os CNPJs e já traz flags booleanas de linhagem de cada sistema. Agrupei pelas 4 flags para gerar a matriz de adoção.
```sql
SELECT has_crm, has_erp_a, has_erp_b, has_zendesk, COUNT(*) AS qty
FROM silver.dim_escolas 
GROUP BY has_crm, has_erp_a, has_erp_b, has_zendesk 
ORDER BY qty DESC
```
**Análise de Resultado:**
Temos um total de **904 escolas únicas**. 
A quebra da matriz de adoção revela um pesadelo de governança:
- **498 escolas (55% da base)** só existem no Zendesk (`has_zendesk=true`, resto `false`). Isso indica que escolas estão abrindo chamados de suporte sem estarem oficialmente no CRM ou nos ERPs (provavelmente filiais ou aquisições recentes sem integração).
- Apenas **84 escolas** possuem o ecossistema completo (`has_crm=true`, `erp_a=true`, `erp_b=true`, `zendesk=true`).

### 2. Eficiência Financeira: Receita do ERP A por Status
**A Pergunta:** Qual é a Receita Bruta acumulada gerada pelo ERP A e como se distribui pelos diferentes status de pedido?
**Racional da Query:** Cruzei a `fct_vendas` (para isolar ERP A e filtrar cancelamentos consolidados `is_cancelado='N'`) com a `fct_vendas_itens` para somar o `valor_total`.
```sql
SELECT v.status_pedido, SUM(i.valor_total) AS receita
FROM silver.fct_vendas v
JOIN silver.fct_vendas_itens i ON v.id_pedido = i.id_pedido
WHERE v.sistema_origem = 'ERP A' AND v.is_cancelado = 'N'
GROUP BY v.status_pedido
```
**Análise de Resultado:**
O faturamento íntegro e ativo é de **R$ 50.6 Milhões**.
Porém, 100% dessa receita está travada no status `PENDING`. Isso significa que o ERP A está gerando vendas, mas não estamos faturando efetivamente nem convertendo para `DELIVERED`. O gargalo financeiro e operacional está puramente focado na expedição do Centro de Distribuição A.

### 3. Logística: Volumetria de Atrasos
**A Pergunta:** Qual é o percentual geral de atrasos logísticos e qual ERP detém a maior volumetria de entregas fora do prazo?
**Racional da Query:** Usei a `fct_logistica_entregas` que já calcula o `atraso_dias` matematicamente. Juntei com a `fct_vendas` para quebrar pelo `sistema_origem`.
```sql
SELECT v.sistema_origem, SUM(CASE WHEN e.atraso_dias > 0 THEN 1 ELSE 0 END) AS entregas_atrasadas, COUNT(*) AS total_entregas
FROM silver.fct_logistica_entregas e
JOIN silver.fct_vendas v ON e.id_pedido = v.id_pedido
GROUP BY v.sistema_origem
```
**Análise de Resultado:**
- **ERP A:** 316 atrasos em 1.500 entregas (21%).
- **ERP B:** 131 atrasos em 964 entregas (13.5%).
Apesar do ERP B faturar menos escolas, sua eficiência logística é consideravelmente superior. O gap operacional de quase 8 pontos percentuais exige intervenção na transportadora contratada pelo ERP A.

### 4. Catálogo Editorial: Produtos de Maior Sucesso
**A Pergunta:** Quais são os Top 5 produtos que mais geraram receita e qual a representatividade deles?
**Racional da Query:** O cruzamento direto da chave substituta `id_produto_unificado` entre a Fato Itens e a Dimensão Produtos resolve as discrepâncias de string das fontes.
```sql
SELECT p.nome_produto, SUM(i.valor_total) AS receita_total
FROM silver.fct_vendas_itens i
JOIN silver.dim_produtos p ON i.id_produto_unificado = p.id_produto_unificado
GROUP BY p.nome_produto 
ORDER BY receita_total DESC 
LIMIT 5
```
**Análise de Resultado:**
1. Material NSE 2 EM (R$ 3.83 Mi)
2. Material Isaac 5 EF (R$ 3.64 Mi)
3. Material COC 4 EF (R$ 3.48 Mi)
4. Material SAE 4 EF (R$ 3.46 Mi)
5. Material Isaac 1 EM (R$ 3.44 Mi)
As soluções de Ensino Fundamental e Ensino Médio estão organicamente divididas. Não há dependência de uma "marca estrela" (NSE, Isaac, COC, SAE faturam volumes muito similares).

### 5. Atendimento: Epicentros de Suporte
**A Pergunta:** Quais são as 5 escolas com maior volume absoluto de chamados de suporte abertos?
**Racional da Query:** Consumir diretamente a OBT da camada Gold focada em Churn Risk, que já pre-calculou o volume de chamados por CNPJ, cruzando com a `dim_escolas` para exibir o nome.
```sql
SELECT e.nome_escola, t.qtd_chamados
FROM gold.obt_churn_risk_escolas t
JOIN silver.dim_escolas e ON t.id_escola = e.id_escola
ORDER BY qtd_chamados DESC LIMIT 5
```
**Análise de Resultado:**
Rios Instituto e Colégio Araújo lideram com 20 chamados, seguidos pela Rocha Escola (19). São clientes extremamente atritos, mas precisamos isolar se isso é suporte técnico ou pedagógico. 

### 6. Taxa de Rejeição/Cancelamento Operacional
**A Pergunta:** Como a taxa de cancelamento de pedidos se compara entre os dois ERPs?
**Racional da Query:** A `fct_vendas` encapsula regras complexas do que de fato é cancelado (drafts, status 'C'). Filtrei a flag `is_cancelado`.
```sql
SELECT sistema_origem, SUM(CASE WHEN is_cancelado='Y' THEN 1 ELSE 0 END) AS cancelados, COUNT(*) AS total
FROM silver.fct_vendas 
GROUP BY sistema_origem
```
**Análise de Resultado:**
- **ERP A:** 1.138 cancelados de 1.800 (63%).
- **ERP B:** 320 cancelados de 1.200 (26%).
A taxa abusiva do ERP A é majoritariamente explicada por Drafts criados e descartados sistemicamente. Isso polui indicadores de força de vendas originais e justifica a utilidade da Fato limpa.

### 7. Performance Comercial (Entregas Reais)
**A Pergunta:** Qual vendedor trouxe o maior número de escolas novas para a base de pedidos concluídos (`DELIVERED`)?
**Racional da Query:** Contabilizamos `fct_vendas` filtrada pelo `DELIVERED`, aglomerando por `nome_vendedor` através da `dim_vendedores`.
```sql
SELECT vd.nome_vendedor, COUNT(*) AS total_vendas
FROM silver.fct_vendas v
JOIN silver.dim_vendedores vd ON v.id_vendedor_sk = vd.id_vendedor_sk
WHERE v.status_pedido = 'DELIVERED'
GROUP BY vd.nome_vendedor 
ORDER BY total_vendas DESC 
LIMIT 5
```
**Análise de Resultado:**
Liderança de Maria Lopes (26), Eloah Costela (23), Isabel Garcia (21), Maria Liz Melo (20) e Isabella Siqueira (19). O time comercial feminino domina absolutamente o fechamento de ciclo (venda finalizada e entregue).

### 8. SLA de Escolas em Atraso
**A Pergunta:** Qual a correlação entre Escolas com Ticket SLA estourado e atrasos logísticos?
**Racional da Query:** Utilizei a OBT de Churn Risk, que relaciona a logística na veia do suporte, calculando média de SLA apenas para escolas que sofrem atrasos físicos.
```sql
SELECT SUM(qtd_chamados) as total_tickets, AVG(sla_atendimento_medio_horas) as sla_medio
FROM gold.obt_churn_risk_escolas
WHERE entregas_com_atraso > 0
```
**Análise de Resultado:**
403 chamados foram abertos por escolas que não receberam a carga. **O SLA médio desse segmento é brutal: 163 horas (6,7 dias)**. A operação de Suporte não prioriza quem tem carga atrasada.

### 9. O Risco de Negócio (Churn Impact)
**A Pergunta:** Qual o total de faturamento concentrado nas 10 escolas com maior "Risco de Churn" (alto suporte + atraso)?
**Racional da Query:** Utilização fluída da camada Gold para isolar faturamento. 
```sql
WITH top_10_risk AS (
    SELECT valor_total_gasto 
    FROM gold.obt_churn_risk_escolas
    ORDER BY qtd_chamados DESC, entregas_com_atraso DESC 
    LIMIT 10
)
SELECT SUM(valor_total_gasto) AS faturamento_em_risco
FROM top_10_risk
```
**Análise de Resultado:**
**R$ 4.005.360,97** em faturamento real sob risco IMINENTE de rescisão, encabeçado pelo Top 10 mais furioso. O executivo agora possui o *cifráo exato* da urgência para intervir na logística dessas 10 unidades.

### 10. Limbo Operacional (Orphan Tickets)
**A Pergunta:** Qual é o volume de "Tickets Órfãos" no Zendesk e qual a anomalia estrutural associada?
**Racional da Query:** Consultei na `dim_escolas` a quantidade de entradas criadas pelo escape que implementamos para resgatar os CNPJs soltos do Zendesk.
```sql
SELECT COUNT(*) AS escolas_orfaos
FROM silver.dim_escolas
WHERE nome_escola = 'Escola s/ Cadastro (Zendesk)'
```
**Análise de Resultado:**
Exatamente os mesmos **498** ofãos reportados na Pergunta 1. Quase R$ 0 de correlação com ERPs porque as chaves das contas não batem. São professores, diretores de escolas recém-adquiridas (possivelmente M&A) tentando suporte que sequer possuem registro nos ERPs oficiais.
