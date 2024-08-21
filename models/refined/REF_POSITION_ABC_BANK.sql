WITH 
current_snapshot_from as (
    {{ current_from_snapshot(snsh_ref = ref('SNSH_ABC_BANK_POSITION')) }}
)
SELECT
    *
    , POSITION_VALUE - COST_BASE as UNREALIZED_PROFIT
    , ROUND(UNREALIZED_PROFIT / COST_BASE, 5) as UNREALIZED_PROFIT_PCT
FROM current_snapshot_from