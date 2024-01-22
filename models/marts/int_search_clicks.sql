{{
   config(
      materialiized='incremental',
      unique_key=['date'],
      incremental_strategy='merge',
      incremental_predicates = ["DBT_INTERNAL_DEST.date >= current_date-1"],
      partition_by={
       "field":"date",
       "data_type":"date",
       "granularity": "day"
      },
      require_partition_filter = false,
      partition_expiration_days = 30,
      tags=["daily"]
   )
}}

with ranked_searches as (
select
    id as searchid,
    visitid,
    datetime as  date_search,
    rank() over (partition by visitid order by date_search asc)as search_rank,
    DATEDIFF(millisecond, LAG(a.datetime) over (partition by a.visitid order by a.datetime) , a.datetime) as diff_time_search
from {{ source ('dimensions', 'searches') }}  a
group by 1,2,3
order by a.datetime)

select
    date (a.datetime) as date,
    a.id,
    a.visitid,
    b.clickid,
    b.clickrank,
    a.c_product,
    b.sourcename,
    a.browser,
    c.search_rank,
    c.diff_time_search,
    a.userid
from {{ source ('dimensions', 'searches') }} a
    join {{source ('dimensions', 'clicks')}} b
on a.id = b.searchid and a.visitid=b.visitid
    join ranked_searches c on a.id= c.searchid















