WITH stg_erp_b_vendedor_raw AS (
    SELECT
        CAST("id_vendedor" AS BIGINT) AS id_vendedor,
        CAST("nome" AS STRING) AS nome,
        {{ hash_pii('CAST("email" AS STRING)') }} AS email,
        CAST("regiao" AS STRING) AS regiao,
        CAST("ativo" AS STRING) AS ativo
    FROM {{ source('erp_b', 'erp_b_vendedor') }}
)
SELECT * FROM stg_erp_b_vendedor_raw