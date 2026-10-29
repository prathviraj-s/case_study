{{ 
    config(
        materialized='incremental'
        ) 
        
}}

select
    a.application_id,
    a.applicant_name,
    a.application_date,
    a.ssn,
    a.loan_amount,
    a.property_price,
    a.monthly_gross_income,
    c.fico,
    c.monthly_debt
from {{ ref('stg_mortgage_applications') }} a
inner join {{ ref('stg_credit_bureau') }} c
    on a.application_id = c.application_id
where a.property_price is not null
    and c.fico is not null