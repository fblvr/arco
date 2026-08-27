WITH source AS (
    SELECT
        CAST("Id" AS VARCHAR) AS id,
        CAST("Name" AS VARCHAR) AS name,
        CAST("RazaoSocial__c" AS VARCHAR) AS razaosocial__c,
        {{ hash_pii(normalize_cnpj('CAST("CNPJ__c" AS VARCHAR)')) }} AS cnpj__c,
        CAST("Type" AS VARCHAR) AS type,
        CAST("ParentId" AS VARCHAR) AS parentid,
        {{ hash_pii(normalize_phone('CAST("Phone" AS VARCHAR)')) }} AS phone,
        CAST("BillingCity" AS VARCHAR) AS billingcity,
        CAST("BillingState" AS VARCHAR) AS billingstate,
        CAST("SalesModality__c" AS VARCHAR) AS salesmodality__c,
        CAST("Segment__c" AS VARCHAR) AS segment__c,
        CAST("OwnerId" AS VARCHAR) AS ownerid,
        CAST("IsDeleted" AS BOOLEAN) AS isdeleted,
        CAST("CreatedDate" AS TIMESTAMP) AS createddate,
        CAST("LastModifiedDate" AS TIMESTAMP) AS lastmodifieddate
    FROM {{ source('crm', 'crm_account') }}
)
SELECT * FROM source