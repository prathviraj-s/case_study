{{ 
    config(
        materialized='table',
        schema='gold'
    ) 
}}

select
    application_id,
    application_name,
    application_date,
    loan_amount,
    property_value,
    fico_score,
    ltv,
    dti,
    reason_code
from {{ ref('underwriting_business_rules') }}