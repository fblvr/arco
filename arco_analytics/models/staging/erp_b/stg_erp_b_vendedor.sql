WITH stg_erp_b_vendedor_raw AS (
    SELECT
        CAST("id_vendedor" AS BIGINT) AS id_vendedor,
        CAST("nome" AS VARCHAR) AS nome,
        {{ hash_pii('CAST("email" AS VARCHAR)') }} AS email,
        CAST("regiao" AS VARCHAR) AS regiao,
        CAST("ativo" AS VARCHAR) AS ativo
    FROM {{ source('erp_b', 'erp_b_vendedor') }}
)
SELECT * FROM stg_erp_b_vendedor_raw