WITH stg_erp_a_sales_order_item_raw AS (
    SELECT
        CAST("DocEntry" AS BIGINT) AS docentry,
        CAST("LineNum" AS BIGINT) AS linenum,
        CAST("ItemCode" AS VARCHAR) AS itemcode,
        CAST("ItemName" AS VARCHAR) AS itemname,
        CAST("Quantity" AS BIGINT) AS quantity,
        CAST("DelivrdQty" AS BIGINT) AS delivrdqty,
        CAST("OpenQty" AS BIGINT) AS openqty,
        CAST("ShipDate" AS DATE) AS shipdate,
        CAST("LineStatus" AS VARCHAR) AS linestatus,
        CAST("Price" AS DOUBLE) AS price,
        CAST("LineTotal" AS DOUBLE) AS linetotal
    FROM {{ source('erp_a', 'erp_a_sales_order_item') }}
)
SELECT * FROM stg_erp_a_sales_order_item_raw