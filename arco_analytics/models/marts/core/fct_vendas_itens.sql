WITH erp_a AS (
    SELECT
        'ERP_A_' || docentry AS id_pedido,
        'ERP_A_' || docentry || '_' || linenum AS id_item_pedido,
        MD5(UPPER(itemname)) AS id_produto_unificado,
        itemcode AS id_produto_origem,
        quantity AS qtd_pedida,
        linetotal AS valor_total,
        'ERP A' AS sistema_origem
    FROM {{ ref('stg_erp_a_sales_order_item') }}
),
erp_b AS (
    SELECT
        'ERP_B_' || id_pedido AS id_pedido,
        'ERP_B_' || id_item AS id_item_pedido,
        MD5(UPPER(desc_produto)) AS id_produto_unificado,
        cod_produto AS id_produto_origem,
        qtd_pedida,
        preco_unitario * qtd_pedida AS valor_total,
        'ERP B' AS sistema_origem
    FROM {{ ref('stg_erp_b_item_pedido') }}
)
SELECT * FROM erp_a
UNION ALL
SELECT * FROM erp_b
