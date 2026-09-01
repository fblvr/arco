WITH stg_crm_contract_line_item_raw AS (
    SELECT
        CAST("Id" AS STRING) AS id,
        CAST("ServiceContractId" AS BIGINT) AS servicecontractid,
        CAST("ProductId" AS STRING) AS productid,
        CAST("MaterialType__c" AS STRING) AS materialtype__c,
        CAST("SchoolGrade__c" AS STRING) AS schoolgrade__c,
        CAST("Segment__c" AS STRING) AS segment__c,
        CAST("Quantity" AS BIGINT) AS quantity,
        CAST("UnitPrice" AS DOUBLE) AS unitprice,
        CAST("Discount" AS DOUBLE) AS discount,
        CAST("TotalPrice" AS DOUBLE) AS totalprice,
        CAST("CreatedDate" AS TIMESTAMP) AS createddate
    FROM {{ source('crm', 'crm_contract_line_item') }}
)
SELECT * FROM stg_crm_contract_line_item_raw