{{ config(materialized='ephemeral') }}

WITH
src_data as (
    SELECT
	    COUNTRY_NAME as COUNTRY_NAME    -- TEXT
	    , COUNTRY_CODE_2_LETTER as COUNTRY_CODE_2_LETTER    -- TEXT
	    , COUNTRY_CODE_3_LETTER as COUNTRY_CODE_3_LETTER    -- TEXT
        , COUNTRY_CODE_NUMERIC as COUNTRY_CODE_NUMERIC      -- NUMBER
        , ISO_3166_2  as ISO_3166_2                         -- TEXT
	    , REGION as REGION                                  -- TEXT
	    , SUB_REGION as SUB_REGION                          -- TEXT
	    , INTERMEDIATE_REGION as INTERMEDIATE_REGION        -- TEXT
	    , REGION_CODE as REGION_CODE                        -- NUMBER
	    , SUB_REGION_CODE as SUB_REGION_CODE                -- NUMBER
	    , INTERMEDIATE_REGION_CODE as INTERMEDIATE_REGION_CODE --NUMBER
	    , LOAD_TS AS LOAD_TS                                -- TIMESTAMP_NTZ
        , 'SEED.ABC_Bank_COUNTRY_INFO' as RECORD_SOURCE
    FROM {{ source('seeds', 'ABC_Bank_COUNTRY_INFO') }}
 ),

default_record as (
    SELECT
	    'Unknown' as COUNTRY_NAME    -- TEXT
	    , 'Missing' as COUNTRY_CODE_2_LETTER    -- TEXT
	    , 'Missing' as COUNTRY_CODE_3_LETTER    -- TEXT
        , -1 as COUNTRY_CODE_NUMERIC      -- NUMBER
        , 'Missing'  as ISO_3166_2                         -- TEXT
	    , 'Missing' as REGION                                  -- TEXT
	    , 'Missing' as SUB_REGION                          -- TEXT
	    , 'Missing' as INTERMEDIATE_REGION        -- TEXT
	    , -1 as REGION_CODE                        -- NUMBER
	    , -1 as SUB_REGION_CODE                -- NUMBER
	    , -1 as INTERMEDIATE_REGION_CODE --NUMBER
	    , '1900-01-01' AS LOAD_TS                                -- TIMESTAMP_NTZ
        , 'Missing' as RECORD_SOURCE
),

with_default_record as(
    SELECT * FROM src_data
    UNION ALL
    SELECT * FROM default_record
),

hashed as (
    SELECT
        concat_ws('|', ISO_3166_2) as COUNTRY_HKEY
        , concat_ws('|', ISO_3166_2, REGION, SUB_REGION,
                         INTERMEDIATE_REGION ) as COUNTRY_HDIFF

        , * EXCLUDE LOAD_TS
        , LOAD_TS as LOAD_TS_UTC
    FROM with_default_record
)
SELECT * FROM hashed
