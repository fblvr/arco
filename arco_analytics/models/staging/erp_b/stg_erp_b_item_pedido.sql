WITH stg_erp_b_item_pedido_raw AS (
    SELECT
        CAST("id_item" AS BIGINT) AS id_item,
        CAST("id_pedido" AS BIGINT) AS id_pedido,
        CAST("cod_produto" AS STRING) AS cod_produto,
        CAST("desc_produto" AS STRING) AS desc_produto,
        CAST("qtd_pedida" AS BIGINT) AS qtd_pedida,
        CAST("preco_unitario" AS DOUBLE) AS preco_unitario,
        CAST("dt_criacao" AS TIMESTAMP) AS dt_criacao
    FROM {{ source('erp_b', 'erp_b_item_pedido') }}
)
SELECT * FROM stg_erp_b_item_pedido_raw