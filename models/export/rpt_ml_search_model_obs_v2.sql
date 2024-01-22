{{
   config(
      materialiized='incremental',
      unique_key=['date'],
      incremental_strategy='merge',
      incremental_predicates = ["DBT_INTERNAL_DEST.date >= current_date"],
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


select a.date,
       searches_w_ckick,
       total_searches,
       vistis_w_click,
       total_visits,
       percentage_search,
       percentage_difference,
       mavg_perc_7days,
       click_rate,
       bounce_rate,
       avg_time_spent,
       avg_sess_visit,
       avg_sess_clicks,
       top_10_keywords,
       top_items,
       top_sources,
       top_browsers
from {{ref('fct_search_metrics')}} a
join {{ref('fct_top_n_metrics')}} b
on a.date=b.date
order by 1 desc