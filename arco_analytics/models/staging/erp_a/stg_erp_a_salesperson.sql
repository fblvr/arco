WITH stg_erp_a_salesperson_raw AS (
    SELECT
        CAST("SlpCode" AS BIGINT) AS slpcode,
        CAST("SlpName" AS STRING) AS slpname,
        CAST("Memo" AS STRING) AS memo,
        CAST("Active" AS STRING) AS active
    FROM {{ source('erp_a', 'erp_a_salesperson') }}
)
SELECT * FROM stg_erp_a_salesperson_raw