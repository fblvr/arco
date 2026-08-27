WITH stg_erp_a_invoice_raw AS (
    SELECT
        CAST("DocEntry" AS BIGINT) AS docentry,
        CAST("DocNum" AS BIGINT) AS docnum,
        CAST("CardCode" AS VARCHAR) AS cardcode,
        CAST("BaseEntry" AS BIGINT) AS baseentry,
        CAST("DocDate" AS DATE) AS docdate,
        CAST("DocTotal" AS DOUBLE) AS doctotal,
        CAST("VatSum" AS DOUBLE) AS vatsum,
        CAST("Cancelled" AS VARCHAR) AS cancelled,
        CAST("CreateDate" AS DATE) AS createdate
    FROM {{ source('erp_a', 'erp_a_invoice') }}
)
SELECT * FROM stg_erp_a_invoice_raw