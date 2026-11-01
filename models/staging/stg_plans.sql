
{{ config(materialized='view') }}

WITH source AS (

    SELECT *
    FROM {{ source('raw', 'plans') }}

),

renamed AS (

    SELECT
        "plan_id" AS plan_id,
        "plan_name" AS plan_name,
        "tier" AS tier,
        "monthly_price"::NUMBER(12,2) AS monthly_price,
        "seat_price"::NUMBER(12,2) AS seat_price,
        LOWER(TRIM("billing_interval")) AS billing_interval,
        "is_active" AS is_active

    FROM source

)

SELECT *
FROM renamed
