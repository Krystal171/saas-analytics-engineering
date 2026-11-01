
WITH mrr_reconciliation AS (

    SELECT
        month_end,
        total_mrr,

        starting_mrr
        + new_mrr
        + reactivation_mrr
        + expansion_mrr
        - contraction_mrr
        - churned_mrr AS calculated_ending_mrr

    FROM {{ ref('fct_monthly_saas_kpis') }}

)

SELECT
    month_end,
    total_mrr,
    calculated_ending_mrr,
    total_mrr - calculated_ending_mrr AS difference

FROM mrr_reconciliation

WHERE
    total_mrr IS NULL
    OR calculated_ending_mrr IS NULL
    OR ABS(total_mrr - calculated_ending_mrr) > 0.01
