select *
from {{ ref('underwriting_business_rules') }}

where fico_score < 620
  and decision <> 'DECLINED'