WITH source AS (
    SELECT
        CAST("CardCode" AS VARCHAR) AS cardcode,
        CAST("CardName" AS VARCHAR) AS cardname,
        {{ hash_pii(normalize_cnpj('CAST("CNPJ" AS VARCHAR)')) }} AS cnpj,
        CAST("City" AS VARCHAR) AS city,
        CAST("State" AS VARCHAR) AS state,
        {{ hash_pii(normalize_phone('CAST("Phone1" AS VARCHAR)')) }} AS phone1,
        CAST("E_Mail" AS VARCHAR) AS e_mail,
        CAST("SlpCode" AS BIGINT) AS slpcode,
        CAST("CreateDate" AS DATE) AS createdate,
        CAST("UpdateDate" AS DATE) AS updatedate
    FROM {{ source('erp_a', 'erp_a_customer') }}
)
SELECT * FROM source