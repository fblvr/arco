WITH stg_crm_product_raw AS (
    SELECT
        CAST("Id" AS STRING) AS id,
        CAST("ProductCode" AS STRING) AS productcode,
        CAST("Name" AS STRING) AS name,
        CAST("Brand__c" AS STRING) AS brand__c,
        CAST("MaterialType__c" AS STRING) AS materialtype__c,
        CAST("IsActive" AS BOOLEAN) AS isactive,
        CAST("CreatedDate" AS TIMESTAMP) AS createddate
    FROM {{ source('crm', 'crm_product') }}
)
SELECT * FROM stg_crm_product_raw