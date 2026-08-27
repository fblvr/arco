WITH escolas AS (
    SELECT * FROM {{ ref('dim_escolas') }}
),
vendas AS (
    SELECT 
        id_cliente as id_escola,
        COUNT(id_pedido) as qtd_pedidos,
        SUM(valor_total) as valor_total_gasto
    FROM (
        SELECT id_pedido, id_cliente, MAX(valor_total) as valor_total 
        FROM (
            SELECT p.id_pedido, p.id_cliente, SUM(i.valor_total) as valor_total
            FROM {{ ref('fct_vendas') }} p
            JOIN {{ ref('fct_vendas_itens') }} i ON p.id_pedido = i.id_pedido
            GROUP BY p.id_pedido, p.id_cliente
        ) GROUP BY id_pedido, id_cliente
    )
    GROUP BY id_cliente
),
entregas AS (
    SELECT
        id_cliente as id_escola,
        COUNT(id_entrega) as total_entregas,
        SUM(CASE WHEN atraso_dias > 0 THEN 1 ELSE 0 END) as entregas_com_atraso,
        AVG(CASE WHEN atraso_dias > 0 THEN atraso_dias ELSE 0 END) as media_dias_atraso
    FROM {{ ref('fct_logistica_entregas') }}
    GROUP BY id_cliente
),
tickets AS (
    SELECT 
        id_cliente as id_escola,
        COUNT(id_ticket) as qtd_chamados,
        AVG(date_diff('hour', created_at, solved_at)) as sla_atendimento_medio_horas
    FROM {{ ref('fct_tickets') }}
    GROUP BY id_cliente
)
SELECT
    e.id_escola,
    e.nome_escola,
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
FROM escolas e
LEFT JOIN vendas v ON e.id_escola = v.id_escola
LEFT JOIN entregas en ON e.id_escola = en.id_escola
LEFT JOIN tickets t ON e.id_escola = t.id_escola
