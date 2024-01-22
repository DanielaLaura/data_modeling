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

{% set import_int_search_clicks = select_table(ref('int_search_clicks'), ref('int_search_clicks_seed')) %}
{% set import_searches = select_table(source('dimensions','searches'), ref('searches_seed')) %}


with search_w_click as (
select
      date,
      count(distinct visitid) as vistis_w_click,
      count(distinct id) as searches_w_ckick
from {{ import_int_search_clicks }}
{%  if is_incremental() %}
where date = current_date -1
{% endif %}
group by 1
),

all_searches as (
select
      date(datetime) as date,
      count(distinct visitid) as total_visits,
      count(distinct id) as total_searches
from {{ import_searches }}
{%  if is_incremental() %}
where date(datetime) = current_date -1
{% endif %}
group by date(datetime)
),

times_spent as (
select
      date_search,
      avg(time_diff) as avg_time_spent
from (
      select
            visitid,
            date(datetime) as  date_search,
            rank() over (partition by visitid order by date_search asc) as search_rank,
            DATEDIFF(millisecond, min(datetime), max(datetime)) as time_diff
      from {{ import_searches }}
      group by 1, date(datetime)
)
{%  if is_incremental() %}
where date_search = current_date -1
{% endif %}
group by 1
order by 2 desc ),

visits_to_sessions as (
select
      date,
      avg(total_searches) as avg_sess_visit
from (
      select
            date(datetime) as date,
            visitid,
            count(distinct id) as total_searches
      from {{ import_searches }}
      group by 1, 2)
{%  if is_incremental() %}
where date = current_date -1
{% endif %}
group by 1
),

session_to_clicks as (
select
      date,
      avg(total_clicks) as avg_sess_clicks
from (
      select
            date,
            id,
            count(distinct clickid) as total_clicks
      from {{ import_int_search_clicks }}
      group by 1, 2)
{%  if is_incremental() %}
where date = current_date -1
{% endif %}
group by 1
),

perentage as (
select
      a.date,
      searches_w_ckick/total_searches*100 as percentage_search
from all_searches a
join search_w_click b on a.date=b.date
{%  if is_incremental() %}
where a.date = current_date -1
{% endif %}
),

observability as (
select
      date,
       percentage_search,
       avg(percentage_search) over (order by date rows between 6 preceding and current row) as mavg_perc_7days
from perentage)

select a.date,
       searches_w_ckick,
       total_searches,
       vistis_w_click,
       total_visits,
       percentage_search,
       (percentage_search - mavg_perc_7days) * 100 / percentage_search as percentage_difference,
       mavg_perc_7days,
       vistis_w_click / total_searches * 100                           as click_rate,
       100 - vistis_w_click / total_visits * 100                       as bounce_rate,
       avg_time_spent,
       avg_sess_visit,
       avg_sess_clicks
from search_w_click a
         join all_searches b on a.date = b.date
         join times_spent c on a.date = c.date_search
         join visits_to_sessions d on a.date = d.date
         join session_to_clicks e on a.date = e.date
         join observability f on a.date = f.date
















