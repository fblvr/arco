WITH source AS (
    SELECT
        CAST("id_escola" AS BIGINT) AS id_escola,
        CAST("nome_escola" AS VARCHAR) AS nome_escola,
        {{ hash_pii(normalize_cnpj('CAST("cnpj" AS VARCHAR)')) }} AS cnpj,
        CAST("cidade" AS VARCHAR) AS cidade,
        CAST("estado" AS VARCHAR) AS estado,
        {{ hash_pii('CAST("email" AS VARCHAR)') }} AS email,
        CAST("id_vendedor" AS BIGINT) AS id_vendedor,
        CAST("dt_cadastro" AS DATE) AS dt_cadastro,
        CAST("dt_atualizacao" AS DATE) AS dt_atualizacao
    FROM {{ source('erp_b', 'erp_b_escola') }}
)
SELECT * FROM source