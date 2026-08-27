WITH erp_a AS (
    SELECT
        'ERP_A_' || CAST(o.docentry AS VARCHAR) AS id_pedido,
        c.cnpj AS id_cliente,
        o.docdate AS data_pedido,
        'ERP_A_' || CAST(o.slpcode AS VARCHAR) AS id_vendedor_sk,
        {{ normalize_status('o.docstatus') }} AS status_pedido,
        o.cancelled AS is_cancelado,
        'ERP A' AS sistema_origem
    FROM {{ ref('stg_erp_a_sales_order') }} o
    LEFT JOIN {{ ref('stg_erp_a_customer') }} c ON o.cardcode = c.cardcode
),
erp_b AS (
    SELECT
        'ERP_B_' || CAST(p.id_pedido AS VARCHAR) AS id_pedido,
        e.cnpj AS id_cliente,
        p.dt_pedido AS data_pedido,
        'ERP_B_' || CAST(p.id_vendedor AS VARCHAR) AS id_vendedor_sk,
        {{ normalize_status('p.status') }} AS status_pedido,
        'N' AS is_cancelado,
        'ERP B' AS sistema_origem
    FROM {{ ref('stg_erp_b_pedido') }} p
    LEFT JOIN {{ ref('stg_erp_b_escola') }} e ON p.id_escola = e.id_escola
)
SELECT * FROM erp_a
UNION ALL
SELECT * FROM erp_b
