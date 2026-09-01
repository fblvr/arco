WITH stg_erp_a_customer_raw AS (
    SELECT
        CAST("CardCode" AS STRING) AS cardcode,
        CAST("CardName" AS STRING) AS cardname,
        {{ hash_pii(normalize_cnpj('CAST("CNPJ" AS STRING)')) }} AS cnpj,
        CAST("City" AS STRING) AS city,
        CAST("State" AS STRING) AS state,
        {{ hash_pii(normalize_phone('CAST("Phone1" AS STRING)')) }} AS phone1,
        CAST("E_Mail" AS STRING) AS e_mail,
        CAST("SlpCode" AS BIGINT) AS slpcode,
        CAST("CreateDate" AS DATE) AS createdate,
        CAST("UpdateDate" AS DATE) AS updatedate
    FROM {{ source('erp_a', 'erp_a_customer') }}
)
SELECT * FROM stg_erp_a_customer_raw