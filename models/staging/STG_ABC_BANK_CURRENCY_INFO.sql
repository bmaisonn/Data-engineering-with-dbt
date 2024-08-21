{{ config(materialized='ephemeral') }}

WITH
src_data as (
  SELECT
	NAME as CURRENCY_NAME,
	ID as CURRENCY_CODE,
	COUNTRY as COUNTRY, 
	CITY as CITY,
	ZONE as ZONE,
	DELTA as DELTA,
	DST_PERIOD as DST_PERIOD,
	OPEN as OPEN,
	CLOSE as CLOSE,
	LUNCH as LUNCH,
	OPEN_UTC as OPEN_UTC,
	CLOSE_UTC as CLOSE_UTC,
	LUNCH_UTC as LUNCH_UTC,
	LOAD_TS as LOAD_TS,
    'SEED.ABC_Bank_CURRENCY_INFO' as RECORD_SOURCE
    FROM {{ source('seeds', 'ABC_Bank_CURRENCY_INFO') }}
 ),

default_record as (
    SELECT
	    'Unknown' as CURRENCY_NAME    -- TEXT
	    , 'Unknown' as CURRENCY_CODE    -- TEXT
	    , 'Missing' as COUNTRY    -- TEXT
        , 'Missing' as CITY
        , 'Missing' as ZONE      -- NUMBER
        , 0.0  as DELTA                         -- TEXT
	    , 'Missing' as DST_PERIOD                                  -- TEXT
	    , 'Missing' as OPEN                          -- TEXT
	    , 'Missing' as CLOSE        -- TEXT
	    , 'Missing' as LUNCH                        -- NUMBER
	    , 'Missing' as OPEN_UTC                -- NUMBER
	    , 'Missing' as CLOSE_UTC --NUMBER
	    , 'Missing' AS LUNCH_UTC                                -- TIMESTAMP_NTZ
        , '1900-01-01' as LOAD_TS
        , 'Missing' as RECORD_SOURCE
),

with_default_record as(
    SELECT * FROM src_data
    UNION ALL
    SELECT * FROM default_record
),

hashed as (
    SELECT
        concat_ws('|', CURRENCY_CODE) as CURRENCY_HKEY
        , concat_ws('|', CURRENCY_NAME, COUNTRY, ZONE,
                         DELTA, DST_PERIOD, OPEN, CLOSE, LUNCH,
                         OPEN_UTC, CLOSE_UTC, LUNCH_UTC, LOAD_TS) as CURRENCY_HDIFF

        , * EXCLUDE LOAD_TS
        , LOAD_TS as LOAD_TS_UTC
    FROM with_default_record
)
SELECT * FROM hashed
