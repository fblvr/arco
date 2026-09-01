WITH stg_crm_account_raw AS (
    SELECT
        CAST("Id" AS STRING) AS id,
        CAST("Name" AS STRING) AS name,
        CAST("RazaoSocial__c" AS STRING) AS razaosocial__c,
        {{ hash_pii(normalize_cnpj('CAST("CNPJ__c" AS STRING)')) }} AS cnpj__c,
        CAST("Type" AS STRING) AS type,
        CAST("ParentId" AS STRING) AS parentid,
        {{ hash_pii(normalize_phone('CAST("Phone" AS STRING)')) }} AS phone,
        CAST("BillingCity" AS STRING) AS billingcity,
        CAST("BillingState" AS STRING) AS billingstate,
        CAST("SalesModality__c" AS STRING) AS salesmodality__c,
        CAST("Segment__c" AS STRING) AS segment__c,
        CAST("OwnerId" AS STRING) AS ownerid,
        CAST("IsDeleted" AS BOOLEAN) AS isdeleted,
        CAST("CreatedDate" AS TIMESTAMP) AS createddate,
        CAST("LastModifiedDate" AS TIMESTAMP) AS lastmodifieddate
    FROM {{ source('crm', 'crm_account') }}
)
SELECT * FROM stg_crm_account_raw