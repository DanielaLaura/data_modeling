{{ config(tags=['unit-test']) }}
 -- depends on: {{ ref('int_search_clicks_seed') }}
 -- depends on {{ ref('searches_seed') }}

{% set options = {"include_missing_columns": true} %}

{% call dbt_unit_testing.test('fct_search_metrics', 'Test default case', options={"run_as_incremental":"True"})  %}
   {% call dbt_unit_testing.mock_ref('int_search_clicks_seed')  %}
    select
     DATE('2019-10-15') as date,
     'e7441e4f-1e3b-4d28-8d9c-953df0995210' as id
    union all
    select
     DATE('2019-10-15') as date,
     '41fa876f-b246-4e5a-b93f-a106dec0eec6' as id
   {% endcall %}

   {% call dbt_unit_testing.expect()  %}
    select
    9  as searches_w_ckick

   {% endcall %}
{% endcall %}