WITH stg_erp_a_delivery_raw AS (
    SELECT
        CAST("DocEntry" AS BIGINT) AS docentry,
        CAST("DocNum" AS BIGINT) AS docnum,
        CAST("CardCode" AS STRING) AS cardcode,
        CAST("BaseEntry" AS BIGINT) AS baseentry,
        CAST("DocDate" AS DATE) AS docdate,
        CAST("DocStatus" AS STRING) AS docstatus,
        CAST("Cancelled" AS STRING) AS cancelled,
        CAST("CreateDate" AS DATE) AS createdate
    FROM {{ source('erp_a', 'erp_a_delivery') }}
)
SELECT * FROM stg_erp_a_delivery_raw