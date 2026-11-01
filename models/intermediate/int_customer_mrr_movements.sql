
{{ config(materialized='view') }}

WITH customer_months AS (

    SELECT
        month_end,
        organization_id,
        customer_mrr
    FROM {{ ref('int_customer_monthly_spine') }}

),

previous_month AS (

    SELECT
        month_end,
        organization_id,
        customer_mrr,

        LAG(customer_mrr, 1, 0) OVER (
            PARTITION BY organization_id
            ORDER BY month_end
        ) AS previous_mrr

    FROM customer_months

),

payment_history AS (

    SELECT
        *,

        COALESCE(
            MAX(
                CASE
                    WHEN customer_mrr > 0 THEN 1
                    ELSE 0
                END
            ) OVER (
                PARTITION BY organization_id
                ORDER BY month_end
                ROWS BETWEEN UNBOUNDED PRECEDING
                         AND 1 PRECEDING
            ),
            0
        ) AS has_paid_before

    FROM previous_month

),

classified AS (

    SELECT
        month_end,
        organization_id,
        previous_mrr,
        customer_mrr,
        has_paid_before,

        CASE
            WHEN previous_mrr = 0
             AND customer_mrr > 0
             AND has_paid_before = 0
                THEN 'new'

            WHEN previous_mrr = 0
             AND customer_mrr > 0
             AND has_paid_before = 1
                THEN 'reactivation'

            WHEN previous_mrr > 0
             AND customer_mrr = 0
                THEN 'churn'

            WHEN previous_mrr > 0
             AND customer_mrr > previous_mrr
                THEN 'expansion'

            WHEN previous_mrr > 0
             AND customer_mrr < previous_mrr
                THEN 'contraction'

            WHEN previous_mrr > 0
             AND customer_mrr = previous_mrr
                THEN 'retained'

            ELSE 'non_paying'
        END AS movement_type

    FROM payment_history

)

SELECT
    month_end,
    organization_id,
    previous_mrr,
    customer_mrr,
    has_paid_before,
    movement_type,

    CASE
        WHEN movement_type = 'new'
            THEN customer_mrr
        ELSE 0
    END AS new_mrr,

    CASE
        WHEN movement_type = 'reactivation'
            THEN customer_mrr
        ELSE 0
    END AS reactivation_mrr,

    CASE
        WHEN movement_type = 'expansion'
            THEN customer_mrr - previous_mrr
        ELSE 0
    END AS expansion_mrr,

    CASE
        WHEN movement_type = 'contraction'
            THEN previous_mrr - customer_mrr
        ELSE 0
    END AS contraction_mrr,

    CASE
        WHEN movement_type = 'churn'
            THEN previous_mrr
        ELSE 0
    END AS churned_mrr

FROM classified
