{{
  config(
    materialized = 'incremental',
    transient = False,
    unique_key = ['date', 'run_id', 'model'],
    incremental_strategy='merge',
    incremental_predicates = ["DBT_INTERNAL_DEST.date >= current_date-1"]
  )
}}

with empty_table as (
    select
        date(null) as date,
        cast(null as string)  as model,
        CAST(null AS string) as run_id,
        cast(null as  string) as status,
        cast(null as string) as message,
        cast(null as float) as execution_time,
        cast(null as int) as rows_affected

)

select * from empty_table
-- This is a filter so we will never actually insert these values
where 1 = 0
