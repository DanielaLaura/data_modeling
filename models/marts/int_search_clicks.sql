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

select
date(a.datetime) as date,
a.id,
a.visitid,
b.clickid,
b.clickrank,
a.c_product,
b.sourcename,
a.browser
from {{ source('dimensions','searches') }} a
join {{source('dimensions','clicks')}} b on a.id = b.searchid and  a.visitid=b.visitid















