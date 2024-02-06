{% macro log_dbt_run_results(results) %}
-- depends on: {{ ref('dbt_run_results') }}
    {# This macro parses the returned  list of dictionaries from macro parse_dbt_results #}
    {# and inserst their corresponding valuers to dbt_test_result table #}
    {%- if execute -%}
    {%- set parsed_results = parse_dbt_run_results(result) -%}
        {%- if parsed_results | length > 0 -%}
            {% set insert_dbt_results_query -%}
                  insert into {{ ref('dbt_run_results') }}
                    (
                     date,
                     model,
                     run_id,
                     status,
                     message,
                     execution_time,
                     rows_affected
                    ) values
                        {%- for parsed_result_dict in parsed_results -%}
                        {# Last 3 values are obtained as they are since they have the right data type, the rest are passed as strings #}
                        (
                         '{{ parsed_result_dict.get('date') }}',
                         '{{ parsed_result_dict.get('model') }}'.
                         '{{ parsed_result_dict.get('run_id') }}',
                         '{{ parsed_result_dict.get('status') }}',
                         '{{ parsed_result_dict.get('message') }}',
                         {{ parsed_result_dict.get('execution_time') }},
                         {{ parsed_result_dict.get('rows_affected') }}
                        )
                        {%- endfor -%}
            {%- endset -%}
            {%- do run_query(insert_dbt_results_query) -%}
        {%- endif -%}
    {%- endif -%}
    {{ return ('') }}
{% endmacro %}

