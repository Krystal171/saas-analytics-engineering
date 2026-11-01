
{{ config(materialized='view') }}

WITH RECURSIVE

subscription_dates AS (

    SELECT *
    FROM {{ ref('int_subscription_revenue') }}

),

date_bounds AS (

    SELECT
        LAST_DAY(MIN(started_on)) AS first_month_end,
        LAST_DAY(CURRENT_DATE()) AS last_month_end
    FROM subscription_dates

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

subscription_monthly AS (

    SELECT
        m.month_end,
        s.subscription_id,
        s.organization_id,
        s.plan_id,
        s.plan_name,
        s.tier,
        s.billing_interval,
        s.seats,
        s.started_on,
        s.ended_on,
        s.subscription_mrr

    FROM months m
    INNER JOIN subscription_dates s
        ON s.started_on <= m.month_end
       AND (
            s.ended_on IS NULL
            OR s.ended_on > m.month_end
       )

)

SELECT *
FROM subscription_monthly
