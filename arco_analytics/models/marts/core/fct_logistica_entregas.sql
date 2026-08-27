WITH erp_a AS (
    SELECT
        'ERP_A_' || CAST(d.docentry AS VARCHAR) AS id_entrega,
        'ERP_A_' || CAST(d.baseentry AS VARCHAR) AS id_pedido,
        c.cnpj AS id_cliente,
        o.docdate AS data_pedido,
        d.docdate AS data_entrega_real,
        o.docduedate AS data_entrega_prevista,
        date_diff('day', CAST(o.docduedate AS DATE), CAST(d.docdate AS DATE)) AS atraso_dias,
        {{ normalize_status('d.docstatus') }} AS status_entrega,
        'ERP A' AS sistema_origem
    FROM {{ ref('stg_erp_a_delivery') }} d
    LEFT JOIN {{ ref('stg_erp_a_sales_order') }} o ON d.baseentry = o.docentry
    LEFT JOIN {{ ref('stg_erp_a_customer') }} c ON o.cardcode = c.cardcode
),
erp_b AS (
    SELECT
        'ERP_B_NF_' || CAST(nf.id_nf AS VARCHAR) AS id_entrega,
        'ERP_B_' || CAST(nf.id_pedido_erp_b AS VARCHAR) AS id_pedido,
        e.cnpj AS id_cliente,
        p.dt_pedido AS data_pedido,
        nf.dt_entrega_real AS data_entrega_real,
        nf.dt_prevista_entrega AS data_entrega_prevista,
        date_diff('day', CAST(nf.dt_prevista_entrega AS DATE), CAST(nf.dt_entrega_real AS DATE)) AS atraso_dias,
        {{ normalize_status('nf.status_entrega') }} AS status_entrega,
        'ERP B / NF' AS sistema_origem
    FROM {{ ref('stg_fin_nota_fiscal') }} nf
    LEFT JOIN {{ ref('stg_erp_b_pedido') }} p ON nf.id_pedido_erp_b = p.id_pedido
    LEFT JOIN {{ ref('stg_erp_b_escola') }} e ON p.id_escola = e.id_escola
)
SELECT * FROM erp_a
UNION ALL
SELECT * FROM erp_b
