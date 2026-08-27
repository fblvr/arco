WITH source AS (
    SELECT
        CAST("id" AS BIGINT) AS id,
        CAST("name" AS VARCHAR) AS name,
        {{ hash_pii('CAST("email" AS VARCHAR)') }} AS email,
        {{ hash_pii(normalize_phone('CAST("phone" AS VARCHAR)')) }} AS phone,
        CAST("organization_id" AS BIGINT) AS organization_id,
        CAST("role" AS VARCHAR) AS role,
        CAST("is_active" AS BOOLEAN) AS is_active,
        CAST("created_at" AS TIMESTAMP) AS created_at,
        CAST("updated_at" AS TIMESTAMP) AS updated_at
    FROM {{ source('atendimento', 'support_user') }}
)
SELECT * FROM source