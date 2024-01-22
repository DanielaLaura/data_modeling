select
   date,
   percentage,
   mavg_perc_7days,
   percentage_difference
from {{ ref('fct_search_metrics')}}
having not percentage_difference >= 10%
and  not percentage_difference <= -10%