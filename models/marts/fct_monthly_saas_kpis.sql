
{{ config(materialized='view') }}

WITH customer_movements AS (

    SELECT *
    FROM {{ ref('int_customer_mrr_movements') }}

),

monthly_aggregates AS (

    SELECT
        month_end,

        SUM(customer_mrr)::NUMBER(18,2) AS total_mrr,
        SUM(previous_mrr)::NUMBER(18,2) AS starting_mrr,

        COUNT_IF(customer_mrr > 0) AS paying_customers,
        COUNT_IF(previous_mrr > 0) AS starting_paying_customers,

        COUNT_IF(movement_type = 'new') AS new_customers,
        COUNT_IF(movement_type = 'reactivation')
            AS reactivated_customers,
        COUNT_IF(movement_type = 'churn') AS churned_customers,

        SUM(new_mrr)::NUMBER(18,2) AS new_mrr,
        SUM(reactivation_mrr)::NUMBER(18,2) AS reactivation_mrr,
        SUM(expansion_mrr)::NUMBER(18,2) AS expansion_mrr,
        SUM(contraction_mrr)::NUMBER(18,2) AS contraction_mrr,
        SUM(churned_mrr)::NUMBER(18,2) AS churned_mrr

    FROM customer_movements

    GROUP BY month_end

)

SELECT
    *,

    CASE
        WHEN starting_paying_customers > 0
        THEN (
            churned_customers * 100.0
            / starting_paying_customers
        )::NUMBER(10,2)
        ELSE NULL
    END AS customer_churn_rate_pct,

    CASE
        WHEN starting_mrr > 0
        THEN (
            (
                starting_mrr
                + expansion_mrr
                - contraction_mrr
                - churned_mrr
            ) * 100.0 / starting_mrr
        )::NUMBER(10,2)
        ELSE NULL
    END AS nrr_pct

FROM monthly_aggregates
