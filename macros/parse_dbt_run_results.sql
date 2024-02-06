{% macro parse_dbt_run_results(results) %}
   {# This macro parses the resulys artifact object and returns a list of dictionaries for each test/run #}
   {# Create a list of parsed results #}
   {% set parsed_results = [] %}
   {# Args section of run_result is not part of the results obj.; it can be accessed from invocation_args_dict #}
   {% set node_type = invocation_args_dict["which"] %}
   {# Access artifact only if the node is a test or a model; flatten results and add to a list #}
   {% if node_type == 'run'  %}
        {% for run_result in results %}
           {# Convert the run result object to a simple dictionary #}
           {% set run_result_dict = run_result.to_dict() %}
           {# Get the underlying dbt graph node that was executed; the structure of the results section is not the same at the run_results.json #}
           {% set node = run_result_dict.get('node') %}
           {% set rows_affected = run_result_dict["adapter_response"]["rows_affected"] %}
           {%- if not rows_affected -%}
                {% set rows_affected = 0 %}
           {%- endif -%}
           {% set run_id = node.get('unique_id').split('.')[2] %}
           {% set model = invocation_args_dict["select"][0] %}
           {% set status = run_result_dict.get("status") %}
           {# Rows affected == test condition failed; considered only for failed tests #}
           {%-  if status == 'pass' and rows_affected -%}
                 {% set rows_affected = 0 %}
           {%- endif -%}
           {% set date = run_result_dict.get("timing")[1]["completed_at"].split('T')[0] %}
           {% set message = run_result_dict.get("message") %}
           {% set execution_time = run_result_dict.get("execution_time") %}
           {% set parsed_result_runs_dict = {
                'date': date,
                'model': model,
                'run_id': run_id,
                'status': status,
                'message': message,
                'execution_time': execution_time,
                'rows_affected': rows_affected,

             }%}
        {% do parsed_results.append(parsed_result_runs_dict) %}
        {% endfor %}
   {% endif %}
   {{ return(parsed_results) }}
{% endmacro %}