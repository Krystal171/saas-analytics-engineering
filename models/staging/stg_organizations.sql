
{{ config(materialized='view') }}

WITH source AS (

    SELECT *
    FROM {{ source('raw', 'organizations') }}

),

renamed AS (

    SELECT
        "organization_id" AS organization_id,
        "org_name" AS organization_name,
        "industry" AS industry,
        "country" AS country,
        "employee_band" AS employee_band,
        "signed_up_on"::DATE AS signed_up_on,
        "acquisition_channel" AS acquisition_channel

    FROM source

)

SELECT *
FROM renamed
