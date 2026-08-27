WITH stg_support_organization_raw AS (
    SELECT
        CAST("id" AS BIGINT) AS id,
        CAST("name" AS VARCHAR) AS name,
        CAST("details" AS VARCHAR) AS details,
        {{ hash_pii(clean_cnpj('CAST("external_id" AS VARCHAR)')) }} AS external_id,
        CAST("domain_names" AS VARCHAR) AS domain_names,
        CAST("created_at" AS TIMESTAMP) AS created_at,
        CAST("updated_at" AS TIMESTAMP) AS updated_at
    FROM {{ source('atendimento', 'support_organization') }}
)
SELECT * FROM stg_support_organization_raw