WITH tickets AS (
    SELECT
        t.id AS id_ticket,
        COALESCE(o.external_id, t.custom_field_cnpj) AS id_cliente,
        t.custom_field_order_ref AS id_pedido_ref,
        t.created_at,
        t.solved_at,
        {{ normalize_status('t.status') }} AS status,
        t.priority
    FROM {{ ref('stg_support_ticket') }} t
    LEFT JOIN {{ ref('stg_support_organization') }} o ON t.organization_id = o.id
    WHERE COALESCE(o.external_id, t.custom_field_cnpj) IS NOT NULL
)
SELECT * FROM tickets
