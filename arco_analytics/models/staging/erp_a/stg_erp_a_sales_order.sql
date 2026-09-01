WITH stg_erp_a_sales_order_raw AS (
    SELECT
        CAST("DocEntry" AS BIGINT) AS docentry,
        CAST("DocNum" AS BIGINT) AS docnum,
        CAST("CardCode" AS STRING) AS cardcode,
        CAST("NumAtCard" AS STRING) AS numatcard,
        CAST("DocDate" AS DATE) AS docdate,
        CAST("DocDueDate" AS DATE) AS docduedate,
        CAST("DocStatus" AS STRING) AS docstatus,
        CAST("Cancelled" AS STRING) AS cancelled,
        CAST("Comments" AS STRING) AS comments,
        CAST("SlpCode" AS BIGINT) AS slpcode,
        CAST("CreateDate" AS DATE) AS createdate,
        CAST("UpdateDate" AS DATE) AS updatedate
    FROM {{ source('erp_a', 'erp_a_sales_order') }}
)
SELECT * FROM stg_erp_a_sales_order_raw