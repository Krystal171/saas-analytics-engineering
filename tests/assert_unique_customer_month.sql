
SELECT
    organization_id,
    month_end,
    COUNT(*) AS row_count
FROM {{ ref('fct_customer_monthly') }}
GROUP BY
    organization_id,
    month_end
HAVING COUNT(*) > 1
