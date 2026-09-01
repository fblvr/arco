WITH stg_erp_b_pedido_raw AS (
    SELECT
        CAST("id_pedido" AS BIGINT) AS id_pedido,
        CAST("id_escola" AS BIGINT) AS id_escola,
        CAST("num_contrato" AS STRING) AS num_contrato,
        CAST("dt_pedido" AS DATE) AS dt_pedido,
        CAST("dt_entrega_prevista" AS DATE) AS dt_entrega_prevista,
        {{ normalize_status('CAST("status" AS STRING)') }} AS status,
        CAST("id_vendedor" AS BIGINT) AS id_vendedor,
        CAST("dt_criacao" AS TIMESTAMP) AS dt_criacao,
        CAST("dt_atualizacao" AS TIMESTAMP) AS dt_atualizacao
    FROM {{ source('erp_b', 'erp_b_pedido') }}
)
SELECT * FROM stg_erp_b_pedido_raw