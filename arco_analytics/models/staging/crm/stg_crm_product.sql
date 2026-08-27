WITH stg_crm_product_raw AS (
    SELECT
        CAST("Id" AS VARCHAR) AS id,
        CAST("ProductCode" AS VARCHAR) AS productcode,
        CAST("Name" AS VARCHAR) AS name,
        CAST("Brand__c" AS VARCHAR) AS brand__c,
        CAST("MaterialType__c" AS VARCHAR) AS materialtype__c,
        CAST("IsActive" AS BOOLEAN) AS isactive,
        CAST("CreatedDate" AS TIMESTAMP) AS createddate
    FROM {{ source('crm', 'crm_product') }}
)
SELECT * FROM stg_crm_product_raw