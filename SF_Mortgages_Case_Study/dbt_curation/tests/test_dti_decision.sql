select *
from {{ ref('underwriting_business_rules') }}

where dti > 43
  and reason_code <> 'DECLINED'