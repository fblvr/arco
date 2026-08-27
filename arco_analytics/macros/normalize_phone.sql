{% macro normalize_phone(column_name) %}
    REGEXP_REPLACE(
        REGEXP_REPLACE(CAST({{ column_name }} AS VARCHAR), '^\+?55', '', 'g'), -- Remove o +55 ou 55 inicial
        '[^0-9]', '', 'g' -- Remove o que não for número (espaços, traços, parênteses)
    )
{% endmacro %}
