{% macro parse_dbt_res(results) %}
   {# This macro parses the resulys artifact object and returns a list of dictionaries for each test/run #}
   {# Create a list of parsed results #}
   {% set parsed_results = [] %}
   {% set parsed_results_runs = [] %}
   {# Args section of run_result is not part of the results obj.; it can be accessed from invocation_args_dict #}
   {% set node_type = invocation_args_dict["which"] %}
   {# Access artifact only if the node is a test or a model; flatten results and add to a list #}
   {% for run_result in results %}
           {# Convert the run result object to a simple dictionary #}
           {% set run_result_dict = run_result.to_dict() %}
           {# Get the underlying dbt graph node that was executed; the structure of the results section is not the same at the run_results.json #}
           {% set node = run_result_dict.get('node') %}
           {% set rows_affected = run_result_dict["adapter_response"]["rows_affected"] %}
           {%- if not rows_affected -%}
                {% set rows_affected = 0 %}
           {%- endif -%}
           {% set test_name = node.get('unique_id').split('.')[2] %}
           {% set model = invocation_args_dict["select"][0] %}
           {% set status = run_result_dict.get("status") %}
           {# Rows affected == test condition failed; considered only for failed tests #}
           {%-  if status == 'pass' and rows_affected -%}
                 {% set rows_affected = 0 %}
           {%- endif -%}
           {% set date = run_result_dict.get("timing")[1]["completed_at"].split('T')[0] %}
           {% set message = run_result_dict.get("message") %}
           {% set number_of_failures = run_result_dict.get("failures") %}
           {% set execution_time = run_result_dict.get("execution_time") %}
           {% if node_type == 'test' %}
           {% set parsed_result_dict = {
                'date': date,
                'model': model,
                'test_name': test_name,
                'status': status,
                'message': message,
                'execution_time': execution_time,
                'test_conditions_failed': rows_affected,
                'number_of_rows_affected': number_of_failures,
             }%}
           {% do parsed_results.append(parsed_result_dict) %}
           {% elif node_type == 'run'  %}
           {% set parsed_result_runs_dict = {
                'date': date,
                'model': model,
                'test_name': run_id,
                'status': status,
                'message': message,
                'execution_time': execution_time,
                'rows_affected': rows_affected,

             }%}
           {% endif %}
    {% do parsed_results.append(parsed_result_dict) %}
    {% do parsed_result_runs.append(parsed_result_runs_dict) %}
   {% endfor %}
   {{ return(parsed_results, parsed_result_runs) }}
{% endmacro %}