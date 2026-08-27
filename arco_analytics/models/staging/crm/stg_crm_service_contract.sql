WITH stg_crm_service_contract_raw AS (
    SELECT
        CAST("Id" AS BIGINT) AS id,
        CAST("ContractNumber" AS VARCHAR) AS contractnumber,
        CAST("Name" AS VARCHAR) AS name,
        CAST("AccountId" AS VARCHAR) AS accountid,
        CAST("OwnerId" AS VARCHAR) AS ownerid,
        CAST("Status" AS VARCHAR) AS status,
        CAST("StartDate" AS DATE) AS startdate,
        CAST("EndDate" AS DATE) AS enddate,
        CAST("Brand__c" AS VARCHAR) AS brand__c,
        CAST("GrandTotal" AS DOUBLE) AS grandtotal,
        CAST("TotalPrice" AS DOUBLE) AS totalprice,
        CAST("Discount" AS DOUBLE) AS discount,
        CAST("MarketingModel__c" AS VARCHAR) AS marketingmodel__c,
        CAST("IsDeleted" AS BOOLEAN) AS isdeleted,
        CAST("CreatedDate" AS TIMESTAMP) AS createddate,
        CAST("LastModifiedDate" AS TIMESTAMP) AS lastmodifieddate
    FROM {{ source('crm', 'crm_service_contract') }}
)
SELECT * FROM stg_crm_service_contract_raw