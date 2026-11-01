
WITH subscription_totals AS (

    SELECT
        month_end,
        SUM(subscription_mrr) AS total_subscription_mrr
    FROM {{ ref('int_subscription_monthly') }}
    GROUP BY month_end

),

customer_totals AS (

    SELECT
        month_end,
        SUM(customer_mrr) AS total_customer_mrr
    FROM {{ ref('fct_customer_monthly') }}
    GROUP BY month_end

)

SELECT
    COALESCE(s.month_end, c.month_end) AS month_end,
    s.total_subscription_mrr,
    c.total_customer_mrr

FROM subscription_totals s

FULL OUTER JOIN customer_totals c
    ON s.month_end = c.month_end

WHERE s.total_subscription_mrr IS DISTINCT FROM c.total_customer_mrr
