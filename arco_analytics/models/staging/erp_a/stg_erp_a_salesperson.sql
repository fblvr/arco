WITH stg_erp_a_salesperson_raw AS (
    SELECT
        CAST("SlpCode" AS BIGINT) AS slpcode,
        CAST("SlpName" AS VARCHAR) AS slpname,
        CAST("Memo" AS VARCHAR) AS memo,
        CAST("Active" AS VARCHAR) AS active
    FROM {{ source('erp_a', 'erp_a_salesperson') }}
)
SELECT * FROM stg_erp_a_salesperson_raw