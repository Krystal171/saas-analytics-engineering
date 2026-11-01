
{{ config(materialized='view') }}

WITH source AS (

    SELECT *
    FROM {{ source('raw', 'subscriptions') }}

),

renamed AS (

    SELECT
        "subscription_id" AS subscription_id,
        "organization_id" AS organization_id,
        "plan_id" AS plan_id,
        "started_on"::DATE AS started_on,
        "ended_on"::DATE AS ended_on,
        "seats" AS seats,
        "cancel_reason" AS cancel_reason

    FROM source

)

SELECT *
FROM renamed
