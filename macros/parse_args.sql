{%  macro parse_args() %}
{{ print(invocation_args_dict["which"]) }}
{% for run_result in results %}
     {% set run_result_dict = run_result.to_dict() %}
     {{ print(run_result_dict) }}
{% endfor %}
{% endmacro %}