{{ 
    config(
        materialized='view'
        ) 
        
}}

select
    raw_data:app_id::varchar as application_id,
    raw_data:app_name::varchar as applicant_name,  
    try_to_date(raw_data:app_date::varchar) as application_date,
    try_to_number(raw_data:loan_amount::varchar) as loan_amount,
    try_to_number(raw_data:property_price::varchar) as property_price,
    try_to_number(raw_data:monthly_gross_income::varchar) as monthly_gross_income,    
    source_file,
    load_timestamp
from {{ source('bronze', 'mortgage_applications') }}