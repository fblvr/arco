WITH erp_a AS (
    SELECT
        'ERP_A_' || CAST(docentry AS VARCHAR) AS id_pedido,
        'ERP_A_' || CAST(docentry AS VARCHAR) || '_' || CAST(linenum AS VARCHAR) AS id_item_pedido,
        itemcode AS id_produto_origem,
        quantity AS qtd_pedida,
        linetotal AS valor_total,
        'ERP A' AS sistema_origem
    FROM {{ ref('stg_erp_a_sales_order_item') }}
),
erp_b AS (
    SELECT
        'ERP_B_' || CAST(id_pedido AS VARCHAR) AS id_pedido,
        'ERP_B_' || CAST(id_item AS VARCHAR) AS id_item_pedido,
        cod_produto AS id_produto_origem,
        qtd_pedida,
        preco_unitario * qtd_pedida AS valor_total,
        'ERP B' AS sistema_origem
    FROM {{ ref('stg_erp_b_item_pedido') }}
)
SELECT * FROM erp_a
UNION ALL
SELECT * FROM erp_b
