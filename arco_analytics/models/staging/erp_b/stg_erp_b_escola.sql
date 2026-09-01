WITH stg_erp_b_escola_raw AS (
    SELECT
        CAST("id_escola" AS BIGINT) AS id_escola,
        CAST("nome_escola" AS STRING) AS nome_escola,
        {{ hash_pii(normalize_cnpj('CAST("cnpj" AS STRING)')) }} AS cnpj,
        CAST("cidade" AS STRING) AS cidade,
        CAST("estado" AS STRING) AS estado,
        {{ hash_pii('CAST("email" AS STRING)') }} AS email,
        CAST("id_vendedor" AS BIGINT) AS id_vendedor,
        CAST("dt_cadastro" AS DATE) AS dt_cadastro,
        CAST("dt_atualizacao" AS DATE) AS dt_atualizacao
    FROM {{ source('erp_b', 'erp_b_escola') }}
)
SELECT * FROM stg_erp_b_escola_raw