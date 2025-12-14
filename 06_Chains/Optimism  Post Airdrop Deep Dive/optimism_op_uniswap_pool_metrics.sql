/* Description: Calculate total trades, tokens traded, and USD value of OP tokens traded over the last 35 days. */

WITH 
op_trades AS (
  SELECT 
    date_trunc('DAY', evt_block_time) AS block_hour,
    ABS(amount0 / 10^18) AS trade_amount,
    evt_tx_hash AS tx_hash
  FROM 
    uniswap_v3."Pair_evt_Swap"
  WHERE 
    contract_address IN (
      SELECT 
        pool
      FROM 
        uniswap_v3."view_pools"
      WHERE 
        token0 = '\x4200000000000000000000000000000000000042'
    )
    AND evt_block_time >= now() - INTERVAL '35 days'
  UNION
  SELECT 
    date_trunc('DAY', evt_block_time) AS block_hour,
    ABS(amount1 / 10^18) AS trade_amount,
    evt_tx_hash
  FROM 
    uniswap_v3."Pair_evt_Swap"
  WHERE 
    contract_address IN (
      SELECT 
        pool
      FROM 
        uniswap_v3."view_pools"
      WHERE 
        token1 = '\x4200000000000000000000000000000000000042'
    )
    AND evt_block_time >= now() - INTERVAL '35 days'
),

op_price AS (
  SELECT 
    date_trunc('DAY', hour) AS block_hour,
    AVG(median_price) AS price
  FROM 
    prices."approx_prices_from_dex_data"
  WHERE 
    symbol = 'OP'
    AND hour >= now() - INTERVAL '35 days'
  GROUP BY 
    1
),

op_trades_summary AS (
  SELECT 
    t.block_hour,
    COUNT(DISTINCT tx_hash) AS trade_count,
    SUM(trade_amount) AS trade_amount,
    SUM(trade_amount * p.price) AS usd_trade_amount,
    AVG(p.price) AS price
  FROM 
    op_trades t
  INNER JOIN 
    op_price p ON t.block_hour = p.block_hour
  GROUP BY 
    t.block_hour
  ORDER BY 
    t.block_hour
)

SELECT 
  SUM(trade_count) AS total_trades,
  SUM(trade_amount) AS op_tokens_traded,
  SUM(usd_trade_amount) AS usd_op_traded
FROM 
  op_trades_summary;