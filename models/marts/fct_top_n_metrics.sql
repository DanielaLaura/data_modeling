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



with top_keywords as (
select
     date,
     array_agg(keyword) as top_10_keywords

from (
    select
      a.date,
      c.keyword,
      count(distinct id) as total_searches,
      dense_rank() over (partition by  date order by count(distinct id) desc) as ranked_items,
      round(avg(a.clickrank),2) as avg_rank
    from {{ ref('int_search_clicks') }}  a
    join {{ source('dimensions','keywords') }}  c on a.id=c.searchid
    group by 1,2
    order  by 3 desc
)
where ranked_items <=10
group by 1),

top_items as (
select
    date,
    array_agg(product) as top_items
from (
    select
       date,
       c_product as product,
       dense_rank() over (partition by c_product order by count(distinct id) desc) as ranked_items
    from {{ ref('int_search_clicks') }}
    group by 1, 2
)
where ranked_items <=10
group by 1
),

top_source as (
select
   date,
   array_agg(sourcename) as top_sources
from (
   select
      date,
      sourcename,
       dense_rank() over (partition by sourcename order by count(distinct id) desc) as ranked_items
   from {{ ref('int_search_clicks') }}
   group by 1, 2
)
where ranked_items <=10
group by 1
),

top_browser as (
select
    date,
    array_agg(browser) as top_browsers
from (
    select
       date,
       browser,
       dense_rank() over (partition by browser order by count(distinct id) desc) as ranked_items
    from {{ ref('int_search_clicks') }}
    group by 1, 2
)
where ranked_items <=10
group by 1
),

top_n_users as (
select
    date,
    array_agg(userid) as top_users
from (
    select
      userid,
      date,
      count(distinct id) as total_searches,
      dense_rank() over (partition by userid order by count(distinct id) desc) as ranked_users
    from {{ ref('int_search_clicks') }}
--where CONTAINS(sourcename, 'Confluence')
--and b.documentcategory= 'page'
    group by 1,2
    order by 2 desc
limit 10)
group by 1
)

select a.date,
       top_10_keywords,
       top_items,
       top_sources,
       top_browsers,
       top_users
from top_keywords a
         join top_items b on a.date = b.date
         join top_source c on a.date = c.date
         join top_browser d on a.date = d.date
         join top_n_users e on a.date = e.date














