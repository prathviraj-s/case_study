WITH metrics AS (

    SELECT
        application_id,
        applicant_name,
        ssn,
        loan_amount,
        property_price,
        monthly_gross_income,
        fico,
        monthly_debt,
        application_date,
        ROUND(
            (loan_amount / NULLIF(property_price, 0)) * 100,
            2
        ) AS ltv,
        ROUND(
            (monthly_debt / NULLIF(monthly_gross_income, 0)) * 100,
            2
        ) AS dti

    FROM {{ ref('customer_applications') }}

),

decisions AS (
    SELECT
        *,
        CASE
            WHEN ltv > 95 THEN 'DECLINED'
            WHEN dti > 43 THEN 'DECLINED'
            WHEN fico_score < 620 THEN 'DECLINED'
            WHEN fico_score BETWEEN 620 AND 660
                 AND dti BETWEEN 36 AND 43
                THEN 'REQUIRES_CO_SIGNER'
            ELSE 'APPROVED'
        END AS reason_code
    FROM metrics

)

SELECT *
FROM decisions