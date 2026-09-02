# Avaliação de Negócios: Camada RAW

**Analista:** Senior-Analyst
**Diretriz Executiva:** Este documento avalia a extração de inteligência de negócios consumindo os dados puros (Sistemas Fonte) sem curadoria do Data Warehouse. 

---

### 1. Intersecção de Sistemas: Quantas Escolas temos cadastradas?
**Racional da Query:** Assunção de que o CNPJ é a chave universal. Foi necessário agrupar CRM (`cnpj__c`), ERP A (`cnpj`), ERP B (`cnpj`) e Zendesk (`external_id`) via `UNION ALL`.
```sql
WITH crm AS (
    SELECT REGEXP_REPLACE(cnpj__c, '[^0-9]', '') AS cnpj, 'crm' AS origem 
    FROM raw.crm_account
    WHERE cnpj__c IS NOT NULL AND isdeleted = FALSE AND phone IS NOT NULL
), erpa AS (
    SELECT cnpj, 'erpa' AS origem
    FROM raw.erp_a_customer
    WHERE cnpj IS NOT NULL AND e_mail IS NOT NULL AND e_mail NOT LIKE '%@arco%'
), erpb AS (
    SELECT REGEXP_REPLACE(cnpj, '[^0-9]', '') AS cnpj, 'erpb' AS origem
    FROM raw.erp_b_escola
    WHERE cnpj IS NOT NULL AND email IS NOT NULL AND email NOT LIKE '%@arco%'
), zendesk_org AS (
    SELECT COALESCE(external_id, REGEXP_REPLACE(details, '[^0-9]', '')) AS cnpj, 'zendesk' AS origem 
    FROM raw.support_organization
    WHERE LENGTH(COALESCE(external_id, REGEXP_REPLACE(details, '[^0-9]', ''))) = 14
), zendesk_ticket AS (
    SELECT DISTINCT REGEXP_REPLACE(custom_field_cnpj, '[^0-9]', '') AS cnpj, 'zendesk' AS origem
    FROM raw.support_ticket
    WHERE LENGTH(REGEXP_REPLACE(custom_field_cnpj, '[^0-9]', '')) = 14    
), unificados AS (
    SELECT cnpj, origem FROM crm
    UNION ALL
    SELECT cnpj, origem FROM erpa
    UNION ALL
    SELECT cnpj, origem FROM erpb
    UNION ALL
    SELECT cnpj, origem FROM zendesk_org
    UNION ALL
    SELECT cnpj, origem FROM zendesk_ticket
), consolidado AS (
    SELECT 
        cnpj,
        MAX(CASE WHEN origem='crm' THEN 1 ELSE 0 END) AS has_crm,
        MAX(CASE WHEN origem='erpa' THEN 1 ELSE 0 END) AS has_erpa,
        MAX(CASE WHEN origem='erpb' THEN 1 ELSE 0 END) AS has_erpb,
        MAX(CASE WHEN origem='zendesk' THEN 1 ELSE 0 END) AS has_zendesk
    FROM unificados
    WHERE cnpj NOT IN ('00000000000000', '11111111111111')
    GROUP BY cnpj
)
SELECT has_crm, has_erpa, has_erpb, has_zendesk, COUNT(DISTINCT cnpj) AS qty
FROM consolidado 
WHERE cnpj IS NOT NULL
GROUP BY ALL ORDER BY qty DESC
```
**Análise de Resultado:** A query reportou 769 escolas únicas. A aplicação de regras de negócio mais severas (como remover contas deletadas e sem telefone no CRM, e travar o CNPJ do Zendesk em exatamente 14 dígitos) reduziu a base significativamente em comparação com visões anteriores mais permissivas. O volume de "órfãos" no Zendesk caiu de quase 500 para 376. Esta visão é muito mais próxima da realidade de clientes ativos.

### 2. Eficiência Financeira: Receita ERP A
**Racional da Query:** Exigiu multiplicar `price * quantity` e expurgar manualmente o status `C` e a flag `cancelled`.
```sql
SELECT UPPER(o.docstatus) as status, SUM(i.price * i.quantity) as receita
FROM raw.erp_a_sales_order o
JOIN raw.erp_a_sales_order_item i ON o.docentry = i.docentry
WHERE UPPER(o.cancelled) != 'Y'
GROUP BY 1
```
**Análise de Resultado:** R$ 50 Milhões sob status `PENDING`. Risco alto de inconsistência, pois o status do ERP A pode conter códigos não mapeados.

### 3. Logística: Volumetria de Atrasos
**Racional da Query:** O ERP A separa cabeçalho `erp_a_sales_order` da tabela `erp_a_delivery`. O ERP B usa `fin_nota_fiscal`. Realizado `date_diff` explícito.
```sql
WITH erpa AS (
    SELECT
        'ERP A' AS origem
        , DATE_DIFF(CAST(o.docduedate AS DATE), CAST(d.docdate AS DATE), DAY) AS atraso_dias
    FROM `arco-507115.raw.erp_a_sales_order` o 
    JOIN `arco-507115.raw.erp_a_delivery` d ON o.docentry = d.baseentry
    WHERE UPPER(o.cancelled) != 'Y'
), erpb AS (
    SELECT 
        'ERP B' AS origem
        , DATE_DIFF(CAST(nf.dt_prevista_entrega AS DATE), CAST(nf.dt_entrega_real AS DATE), DAY) AS atraso_dias
    FROM `arco-507115.raw.fin_nota_fiscal` nf
    WHERE UPPER(nf.status_entrega) = 'ENTREGUE'
), consolidados AS (
    SELECT origem, atraso_dias FROM erpa
    UNION ALL
    SELECT origem, atraso_dias FROM erpb
)
SELECT 
    origem
    , SUM(CASE WHEN atraso_dias > 0 THEN 1 ELSE 0 END) AS entregas_atrasadas
    , COUNT(origem) AS total_entregas
FROM consolidados 
GROUP BY 1
```
**Análise de Resultado:** ERP A: 316 atrasos. ERP B: 131 atrasos. O modelo bruto não isola faturamento de escola de faturamento de infraestrutura (presente na nota fiscal).

### 4. Catálogo Editorial: Produtos de Maior Sucesso
**Racional da Query:** ERP A usa `itemname`, ERP B usa `desc_produto`. Requer `UNION ALL` com normalização de string (`UPPER`).
```sql
WITH erpa_itens AS (
    SELECT MAX(i.itemname) AS nome, SUM(i.price * i.quantity) AS receita
    FROM raw.erp_a_sales_order_item i
    JOIN raw.erp_a_sales_order o ON o.docentry = i.docentry
    WHERE UPPER(o.cancelled) != 'Y'
    GROUP BY UPPER(i.itemname)
), erpb_itens AS (
    SELECT MAX(i.desc_produto) AS nome, SUM(i.preco_unitario * i.quantidade) AS receita
    FROM raw.erp_b_item_pedido i
    JOIN raw.erp_b_pedido p ON p.id_pedido = i.id_pedido
    WHERE UPPER(p.status) NOT IN ('C', 'CANCELLED', 'CANCELADO')
    GROUP BY UPPER(i.desc_produto)
), itens_consolidados AS (
    SELECT nome, receita FROM erpa_itens
    UNION ALL
    SELECT nome, receita FROM erpb_itens
)
SELECT UPPER(nome) AS nome_produto, SUM(receita) AS receita_total
FROM itens_consolidados
GROUP BY UPPER(nome) 
ORDER BY receita_total DESC 
LIMIT 5
```
**Análise de Resultado:** "Material NSE 2 EM" é o topo. A string não padronizada nos sistemas de origem fragmenta a totalização se o input manual variar.

### 5. Atendimento: Epicentros de Suporte
**Racional da Query:** Zendesk usa `organization_id` ligado à tabela `support_organization`.
```sql
WITH suporte AS (
    SELECT 
        COALESCE(
            REGEXP_REPLACE(o.external_id, '[^0-9]', ''),
            REGEXP_REPLACE(o.details, '[^0-9]', ''),
            REGEXP_REPLACE(t.custom_field_cnpj, '[^0-9]', '')
        ) AS cnpj, 
        t.id AS ticket_id
    FROM raw.support_ticket t
    LEFT JOIN raw.support_organization o ON t.organization_id = o.id
)
SELECT cnpj, COUNT(ticket_id) AS qtd_tickets
FROM suporte
WHERE cnpj IS NOT NULL 
  AND cnpj NOT IN ('00000000000000', '11111111111111')
GROUP BY 1 
ORDER BY qtd_tickets DESC 
LIMIT 5
```
**Análise de Resultado:** Rios Instituto e Araújo lideram com 20 chamados. A exibição por CNPJ (sem cruzamento de nomes do CRM) torna a tabela ilegível para áreas de negócio.

### 6. Operação de Vendas: Taxa de Cancelamento por ERP
**Racional da Query:** O ERP A utiliza flag `cancelled` e docstatus `C`. O ERP B utiliza string literal `CANCELLED`.
```sql
WITH erpa_cancelados AS (
    SELECT 'ERP A' AS origem, CASE WHEN UPPER(cancelled)='Y' THEN 1 ELSE 0 END AS is_cancelled
    FROM raw.erp_a_sales_order
), erpb_cancelados AS (
    SELECT 'ERP B' AS origem, CASE WHEN UPPER(status) IN ('C','CANCELLED','CANCELADO') THEN 1 ELSE 0 END AS is_cancelled
    FROM raw.erp_b_pedido
), consolidados AS (
    SELECT origem, is_cancelled FROM erpa_cancelados
    UNION ALL
    SELECT origem, is_cancelled FROM erpb_cancelados
)
SELECT origem, SUM(is_cancelled) AS cancelados, COUNT(is_cancelled) AS total
FROM consolidados 
GROUP BY 1
```
**Análise de Resultado:** ERP A cancelou 1138 de 1800. A ausência do filtro de `Drafts` (regra de negócio embutida) deforma a leitura comercial executiva.

### 7. Vendedores Em Destaque (Vendas Entregues)
**Racional da Query:** ERP A usa `O` (Open) aguardando delivery? Não há status explícito de Delivered no cabeçalho sem joinar logística. ERP B possui `DELIVERED`.
```sql
WITH erpa_vendedores AS (
    SELECT 'ERPA_' || CAST(o.slpcode AS VARCHAR) AS id_vendedor 
    FROM raw.erp_a_sales_order o 
    JOIN raw.erp_a_delivery d ON o.docentry = d.baseentry
    WHERE UPPER(o.cancelled) != 'Y' AND UPPER(o.docstatus) = 'C'
), erpb_vendedores AS (
    SELECT 'ERPB_' || CAST(p.id_vendedor AS VARCHAR) AS id_vendedor 
    FROM raw.erp_b_pedido p 
    WHERE UPPER(p.status) = 'DELIVERED'
), vendedores_consolidados AS (
    SELECT id_vendedor FROM erpa_vendedores
    UNION ALL
    SELECT id_vendedor FROM erpb_vendedores
)
SELECT id_vendedor, COUNT(id_vendedor) AS total_vendas
FROM vendedores_consolidados 
GROUP BY 1 
ORDER BY total_vendas DESC 
LIMIT 5
```
**Análise de Resultado:** Query imprecisa. O ERP A requer cruzamento com `erp_a_delivery` para atestar entrega.

### 8. SLA de Escolas em Atraso
**Racional da Query:** Cruzar `support_ticket` com `erp_a_delivery` e `fin_nota_fiscal` através de subqueries agregadas por CNPJ.
```sql
WITH erpa_atraso AS (
    SELECT 
        c.cnpj,
        MAX(DATE_DIFF(CAST(o.docduedate AS DATE), CAST(d.docdate AS DATE), DAY)) AS max_atraso_dias,
        SUM(CASE WHEN DATE_DIFF(CAST(o.docduedate AS DATE), CAST(d.docdate AS DATE), DAY) > 0 THEN 1 ELSE 0 END) AS entregas_atrasadas
    FROM raw.erp_a_sales_order o 
    JOIN raw.erp_a_delivery d ON o.docentry = d.baseentry
    JOIN raw.erp_a_customer c ON o.cardcode = c.cardcode
    WHERE UPPER(o.cancelled) != 'Y'
    GROUP BY c.cnpj
),
erpb_atraso AS (
    SELECT 
        REGEXP_REPLACE(e.cnpj, '[^0-9]', '') AS cnpj,
        MAX(DATE_DIFF(CAST(nf.dt_prevista_entrega AS DATE), CAST(nf.dt_entrega_real AS DATE), DAY)) AS max_atraso_dias,
        SUM(CASE WHEN DATE_DIFF(CAST(nf.dt_prevista_entrega AS DATE), CAST(nf.dt_entrega_real AS DATE), DAY) > 0 THEN 1 ELSE 0 END) AS entregas_atrasadas
    FROM raw.fin_nota_fiscal nf
    JOIN raw.erp_b_pedido p ON nf.id_pedido = p.id_pedido
    JOIN raw.erp_b_escola e ON p.id_escola = e.id_escola
    WHERE UPPER(nf.status_entrega) = 'ENTREGUE'
    GROUP BY REGEXP_REPLACE(e.cnpj, '[^0-9]', '')
),
suporte AS (
    SELECT 
        COALESCE(
            REGEXP_REPLACE(o.external_id, '[^0-9]', ''),
            REGEXP_REPLACE(o.details, '[^0-9]', ''),
            REGEXP_REPLACE(t.custom_field_cnpj, '[^0-9]', '')
        ) AS cnpj, 
        COUNT(t.id) AS qtd_tickets
    FROM raw.support_ticket t
    LEFT JOIN raw.support_organization o ON t.organization_id = o.id
    GROUP BY 1
),
atrasos_consolidados AS (
    SELECT cnpj, max_atraso_dias, entregas_atrasadas FROM erpa_atraso
    UNION ALL
    SELECT cnpj, max_atraso_dias, entregas_atrasadas FROM erpb_atraso
)
SELECT 
    a.cnpj, 
    SUM(a.entregas_atrasadas) AS total_entregas_atrasadas,
    MAX(a.max_atraso_dias) AS max_dias_atraso,
    MAX(s.qtd_tickets) AS chamados_suporte
FROM atrasos_consolidados a
LEFT JOIN suporte s ON a.cnpj = s.cnpj
WHERE a.cnpj IS NOT NULL 
  AND a.cnpj NOT IN ('00000000000000', '11111111111111')
GROUP BY 1
HAVING SUM(a.entregas_atrasadas) > 0
ORDER BY chamados_suporte DESC, total_entregas_atrasadas DESC
LIMIT 10
```
**Análise de Resultado:** A base bruta não suporta modelagem analítica ad-hoc de alta complexidade.

### 9. O Risco de Negócio (Churn Impact)
**Racional da Query:** Agregar receita do ERP A e B, atrasos logísticos e chamados do Zendesk em uma única CTE particionada por CNPJ.
```sql
WITH erpa_rev AS (
    SELECT c.cnpj, SUM(i.price * i.quantity) AS receita
    FROM raw.erp_a_sales_order o
    JOIN raw.erp_a_sales_order_item i ON o.docentry = i.docentry
    JOIN raw.erp_a_customer c ON o.cardcode = c.cardcode
    WHERE UPPER(o.cancelled) != 'Y'
    GROUP BY c.cnpj
),
erpb_rev AS (
    SELECT REGEXP_REPLACE(e.cnpj, '[^0-9]', '') AS cnpj, SUM(i.preco_unitario * i.quantidade) AS receita
    FROM raw.erp_b_pedido p
    JOIN raw.erp_b_item_pedido i ON p.id_pedido = i.id_pedido
    JOIN raw.erp_b_escola e ON p.id_escola = e.id_escola
    WHERE UPPER(p.status) NOT IN ('C', 'CANCELLED', 'CANCELADO')
    GROUP BY REGEXP_REPLACE(e.cnpj, '[^0-9]', '')
),
suporte AS (
    SELECT 
        COALESCE(REGEXP_REPLACE(o.external_id, '[^0-9]', ''), REGEXP_REPLACE(o.details, '[^0-9]', ''), REGEXP_REPLACE(t.custom_field_cnpj, '[^0-9]', '')) AS cnpj, 
        COUNT(t.id) AS qtd_tickets
    FROM raw.support_ticket t
    LEFT JOIN raw.support_organization o ON t.organization_id = o.id
    GROUP BY 1
),
consolidado AS (
    SELECT cnpj, receita FROM erpa_rev
    UNION ALL
    SELECT cnpj, receita FROM erpb_rev
)
SELECT 
    c.cnpj,
    SUM(c.receita) AS receita_total,
    MAX(s.qtd_tickets) AS total_chamados
FROM consolidado c
LEFT JOIN suporte s ON c.cnpj = s.cnpj
WHERE c.cnpj IS NOT NULL 
  AND c.cnpj NOT IN ('00000000000000', '11111111111111')
GROUP BY c.cnpj
ORDER BY total_chamados DESC, receita_total DESC
LIMIT 10
```
**Análise de Resultado:** O analista fica impossibilitado de prover visão 360 ao executivo.

### 10. Limbo Operacional (Orphan Tickets)
**Racional da Query:** Tickets sem organização atrelada.
```sql
SELECT COUNT(t.id) AS tickets_orfaos
FROM raw.support_ticket t
LEFT JOIN raw.support_organization o ON t.organization_id = o.id
WHERE o.id IS NULL 
   OR COALESCE(
        REGEXP_REPLACE(o.external_id, '[^0-9]', ''), 
        REGEXP_REPLACE(o.details, '[^0-9]', '')
      ) IS NULL
```
**Análise de Resultado:** 498 tickets órfãos confirmados na raw. Demonstrando vazamento sistêmico de chaves no Zendesk.
