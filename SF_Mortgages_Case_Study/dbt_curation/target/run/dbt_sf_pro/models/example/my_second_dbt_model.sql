
  create or replace   view dbt_sf.public.my_second_dbt_model
  
  
  
  
  as (
    -- Use the `ref` function to select from other models

select *
from dbt_sf.public.my_first_dbt_model
where id = 1
  );

