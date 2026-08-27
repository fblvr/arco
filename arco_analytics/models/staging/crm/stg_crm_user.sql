WITH stg_crm_user_raw AS (
    SELECT
        CAST("Id" AS VARCHAR) AS id,
        CAST("Name" AS VARCHAR) AS name,
        {{ hash_pii('CAST("Email" AS VARCHAR)') }} AS email,
        CAST("ProfileName" AS VARCHAR) AS profilename,
        CAST("IsActive" AS BOOLEAN) AS isactive,
        CAST("CreatedDate" AS TIMESTAMP) AS createddate,
        CAST("LastModifiedDate" AS TIMESTAMP) AS lastmodifieddate
    FROM {{ source('crm', 'crm_user') }}
)
SELECT * FROM stg_crm_user_raw