{% macro normalize_phone(column_name) %}
    REGEXP_REPLACE(
        REGEXP_REPLACE(CAST({{ column_name }} AS STRING), r'^\+?55', ''), 
        '[^0-9]', '' 
    )
{% endmacro %}
