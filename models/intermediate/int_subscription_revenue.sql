
{{ config(materialized='view') }}

WITH subscriptions AS (

    SELECT *
    FROM {{ ref('stg_subscriptions') }}

),

plans AS (

    SELECT *
    FROM {{ ref('stg_plans') }}

),

subscription_revenue AS (

    SELECT
        s.subscription_id,
        s.organization_id,
        s.plan_id,
        p.plan_name,
        p.tier,
        p.billing_interval,
        s.started_on,
        s.ended_on,
        s.seats,

        p.monthly_price,
        p.seat_price,

        (
            p.monthly_price
            + (p.seat_price * s.seats)
        )::NUMBER(18,2) AS subscription_mrr

    FROM subscriptions s
    LEFT JOIN plans p
        ON s.plan_id = p.plan_id

)

SELECT *
FROM subscription_revenue
