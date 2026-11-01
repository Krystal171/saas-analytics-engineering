
{{ config(materialized='view') }}

SELECT
    month_end,

    -- Revenue metrics
    total_mrr,
    starting_mrr,
    new_mrr,
    reactivation_mrr,
    expansion_mrr,
    contraction_mrr,
    churned_mrr,

    -- Customer metrics
    paying_customers,
    starting_paying_customers,
    new_customers,
    reactivated_customers,
    churned_customers,

    -- Retention metrics
    customer_churn_rate_pct,
    nrr_pct

FROM {{ ref('fct_monthly_saas_kpis') }}

WHERE month_end < DATE_TRUNC('MONTH', CURRENT_DATE())
