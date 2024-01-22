select
   date,
   percentage_search,
   mavg_perc_7days,
   percentage_difference
from {{ ref('fct_search_metrics')}}
having not percentage_difference >= 10
     or not percentage_difference <= -10

