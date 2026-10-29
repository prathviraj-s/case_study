{{ 
    config(
        materialized='view'
        ) 
        
}}


select
    application_id,
    ssn,
    try_to_number(fico) as fico_score,
    try_to_number(monthly_debt) as monthly_debt,
    source_file,
    load_timestamp
from {{ source('bronze', 'credit_bureau') }}