--one row for every customer and every reporting month.

{{ config(materialized='view') }}

WITH RECURSIVE

date_bounds AS (

    SELECT
        LAST_DAY(MIN(started_on)) AS first_month_end,
        LAST_DAY(CURRENT_DATE()) AS last_month_end
    FROM {{ ref('stg_subscriptions') }}

),

months (month_end) AS (

    SELECT first_month_end
    FROM date_bounds

    UNION ALL

    SELECT LAST_DAY(DATEADD(month, 1, month_end))
    FROM months
    WHERE month_end < (
        SELECT last_month_end FROM date_bounds
    )

),

customers AS (

    SELECT
        organization_id,
        signed_up_on
    FROM {{ ref('stg_organizations') }}

),

customer_months AS (

    SELECT
        c.organization_id,
        m.month_end
    FROM customers c
    CROSS JOIN months m
    WHERE c.signed_up_on <= m.month_end

),

customer_revenue AS (

    SELECT
        cm.month_end,
        cm.organization_id,

        COALESCE(f.customer_mrr, 0)::NUMBER(18,2)
            AS customer_mrr,

        COALESCE(f.active_subscriptions, 0)
            AS active_subscriptions

    FROM customer_months cm

    LEFT JOIN {{ ref('fct_customer_monthly') }} f
        ON cm.month_end = f.month_end
       AND cm.organization_id = f.organization_id

)

SELECT
    month_end,
    organization_id,
    customer_mrr,
    active_subscriptions,

    CASE
        WHEN customer_mrr > 0 THEN TRUE
        ELSE FALSE
    END AS is_paying_customer

FROM customer_revenue
