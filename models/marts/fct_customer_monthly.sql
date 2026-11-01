
{{ config(materialized='view') }}

WITH subscription_monthly AS (

    SELECT *
    FROM {{ ref('int_subscription_monthly') }}

),

customer_monthly AS (

    SELECT
        month_end,
        organization_id,

        COUNT(DISTINCT subscription_id)
            AS active_subscriptions,

        SUM(subscription_mrr)::NUMBER(18,2)
            AS customer_mrr

    FROM subscription_monthly

    GROUP BY
        month_end,
        organization_id

)

SELECT
    month_end,
    organization_id,
    active_subscriptions,
    customer_mrr,

    CASE
        WHEN customer_mrr > 0 THEN TRUE
        ELSE FALSE
    END AS is_paying_customer

FROM customer_monthly
