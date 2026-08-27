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
    e.*,
    d.nome_escola
FROM entregas e
LEFT JOIN {{ ref('dim_escolas') }} d ON e.id_cliente = d.id_escola
