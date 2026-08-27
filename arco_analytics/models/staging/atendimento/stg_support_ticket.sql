WITH stg_support_ticket_raw AS (
    SELECT
        CAST("id" AS BIGINT) AS id,
        CAST("subject" AS VARCHAR) AS subject,
        CAST("description" AS VARCHAR) AS description,
        CAST("status" AS VARCHAR) AS status,
        CAST("priority" AS VARCHAR) AS priority,
        CAST("type" AS VARCHAR) AS type,
        CAST("requester_id" AS BIGINT) AS requester_id,
        CAST("submitter_id" AS BIGINT) AS submitter_id,
        CAST("assignee_id" AS BIGINT) AS assignee_id,
        CAST("organization_id" AS BIGINT) AS organization_id,
        CAST("tags" AS VARCHAR) AS tags,
        CAST("custom_field_order_ref" AS BIGINT) AS custom_field_order_ref,
        {{ hash_pii(clean_cnpj('CAST("custom_field_cnpj" AS VARCHAR)')) }} AS custom_field_cnpj,
        CAST("satisfaction_score" AS VARCHAR) AS satisfaction_score,
        CAST("satisfaction_comment" AS VARCHAR) AS satisfaction_comment,
        CAST("created_at" AS TIMESTAMP) AS created_at,
        CAST("updated_at" AS TIMESTAMP) AS updated_at,
        CAST("solved_at" AS TIMESTAMP) AS solved_at,
        CAST("due_at" AS TIMESTAMP) AS due_at
    FROM {{ source('atendimento', 'support_ticket') }}
)
SELECT * FROM stg_support_ticket_raw