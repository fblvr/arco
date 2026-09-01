WITH entregas AS (
    SELECT 
        id_entrega,
        id_pedido,
        id_cliente,
        data_pedido,
        data_entrega_prevista,
        data_entrega_real,
        atraso_dias,
        sistema_origem,
        CASE WHEN atraso_dias > 0 THEN TRUE ELSE FALSE END as is_atrasado
    FROM {{ ref('fct_logistica_entregas') }}
)
SELECT
    e.id_entrega,
    e.pedido_id,
    e.cliente_id,
    e.pedido_data,
    e.data_entrega_prevista,
    e.data_entrega_real,
    e.atraso_dias,
    e.sistema_origem,
    e.is_atrasado,
    d.nome_escola
FROM entregas AS e
LEFT JOIN {{ ref('dim_escolas') }} AS d ON e.cliente_id = d.id_escola
