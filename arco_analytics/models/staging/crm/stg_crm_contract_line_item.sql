WITH stg_crm_contract_line_item_raw AS (
    SELECT
        CAST("Id" AS VARCHAR) AS id,
        CAST("ServiceContractId" AS BIGINT) AS servicecontractid,
        CAST("ProductId" AS VARCHAR) AS productid,
        CAST("MaterialType__c" AS VARCHAR) AS materialtype__c,
        CAST("SchoolGrade__c" AS VARCHAR) AS schoolgrade__c,
        CAST("Segment__c" AS VARCHAR) AS segment__c,
        CAST("Quantity" AS BIGINT) AS quantity,
        CAST("UnitPrice" AS DOUBLE) AS unitprice,
        CAST("Discount" AS DOUBLE) AS discount,
        CAST("TotalPrice" AS DOUBLE) AS totalprice,
        CAST("CreatedDate" AS TIMESTAMP) AS createddate
    FROM {{ source('crm', 'crm_contract_line_item') }}
)
SELECT * FROM stg_crm_contract_line_item_raw