WITH escolas AS (
    SELECT 
        escola_id,
        escola_nome,
        data_cadastro,
        has_crm,
        has_erp_a,
        has_erp_b,
        has_zendesk
    FROM {{ ref('dim_escolas') }}
),
vendas_pedidos AS (
    SELECT 
        p.id_pedido, 
        p.id_cliente, 
        SUM(i.valor_total) AS valor_total
    FROM {{ ref('fct_vendas') }} AS p
    INNER JOIN {{ ref('fct_vendas_itens') }} AS i ON p.id_pedido = i.id_pedido
    GROUP BY p.id_pedido, p.id_cliente
),
vendas_clientes AS (
    SELECT 
        id_pedido, 
        id_cliente, 
        MAX(valor_total) AS valor_total 
    FROM vendas_pedidos 
    GROUP BY id_pedido, id_cliente
),
vendas AS (
    SELECT 
        id_cliente AS id_escola,
        COUNT(id_pedido) AS qtd_pedidos,
        SUM(valor_total) AS valor_total_gasto
    FROM vendas_clientes
    GROUP BY id_cliente
),
entregas AS (
    SELECT
        id_cliente AS id_escola,
        COUNT(id_entrega) AS total_entregas,
        SUM(CASE WHEN atraso_dias > 0 THEN 1 ELSE 0 END) AS entregas_com_atraso,
        AVG(CASE WHEN atraso_dias > 0 THEN atraso_dias ELSE 0 END) AS media_dias_atraso
    FROM {{ ref('fct_logistica_entregas') }}
    GROUP BY id_cliente
),
tickets AS (
    SELECT 
        id_cliente AS id_escola,
        COUNT(id_ticket) AS qtd_chamados,
        AVG(date_diff('hour', created_at, solved_at)) AS sla_atendimento_medio_horas
    FROM {{ ref('fct_tickets') }}
    GROUP BY id_cliente
)
SELECT
    e.escola_id,
    e.escola_nome,
    e.data_cadastro,
    COALESCE(v.qtd_pedidos, 0) AS qtd_pedidos,
    COALESCE(v.valor_total_gasto, 0.0) AS valor_total_gasto,
    COALESCE(en.total_entregas, 0) AS total_entregas,
    COALESCE(en.entregas_com_atraso, 0) AS entregas_com_atraso,
    COALESCE(t.qtd_chamados, 0) AS qtd_chamados,
    t.sla_atendimento_medio_horas,
    e.has_crm,
    e.has_erp_a,
    e.has_erp_b,
    e.has_zendesk
FROM escolas AS e
LEFT JOIN vendas AS v ON e.escola_id = v.id_escola
LEFT JOIN entregas AS en ON e.escola_id = en.id_escola
LEFT JOIN tickets AS t ON e.escola_id = t.id_escola
