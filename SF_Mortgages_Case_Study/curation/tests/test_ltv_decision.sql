select *
from {{ ref('underwriting_business_rules') }}

where ltv > 95
  and reason_code <> 'DECLINED'