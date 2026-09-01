WITH stg_support_user_raw AS (
    SELECT
        CAST("id" AS BIGINT) AS id,
        CAST("name" AS STRING) AS name,
        {{ hash_pii('CAST("email" AS STRING)') }} AS email,
        {{ hash_pii(normalize_phone('CAST("phone" AS STRING)')) }} AS phone,
        CAST("organization_id" AS BIGINT) AS organization_id,
        CAST("role" AS STRING) AS role,
        CAST("is_active" AS BOOLEAN) AS is_active,
        CAST("created_at" AS TIMESTAMP) AS created_at,
        CAST("updated_at" AS TIMESTAMP) AS updated_at
    FROM {{ source('atendimento', 'support_user') }}
)
SELECT * FROM stg_support_user_raw