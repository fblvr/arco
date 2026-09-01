{% macro clean_cnpj(column_name, table_name=none) %}
    {% if table_name == 'support_organization' %}
        COALESCE(REGEXP_REPLACE({{ column_name }}, '[^0-9]', ''), REGEXP_REPLACE(details, '[^0-9]', ''))
    {% else %}
        REGEXP_REPLACE({{ column_name }}, '[^0-9]', '')
    {% endif %}
{% endmacro %}
