{{ 
    config(
        materialized='incremental'
        ) 
        
}}

select
    a.application_id,
    a.applicant_name,
    a.ssn,
    a.loan_amount,
    a.property_price,
    a.monthly_gross_income,
    c.fico,
    c.monthly_debt,
    case
        when a.property_price is null
            then 'MISSING_PROPERTY_VALUE'
        when c.fico is null
            then 'MISSING_CREDIT_SCORE'
    end as rejection_reason
from {{ ref('stg_mortgage_applications') }} a
left join {{ ref('stg_credit_bureau') }} c
    on a.application_id = c.application_id

where  a.property_value is null
    or c.fico_score is null