/* Description: Calculate OP token trade summary and moving average price. */
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
    AND evt_block_time >= NOW() - INTERVAL '35 days'
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
    AND evt_block_time >= NOW() - INTERVAL '35 days'
),

op_price AS (
  SELECT 
    date_trunc('DAY', hour) AS block_hour,
    AVG(median_price) AS price
  FROM 
    prices."approx_prices_from_dex_data"
  WHERE 
    symbol = 'OP'
    AND hour >= NOW() - INTERVAL '35 days'
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
  block_hour,
  trade_count,
  trade_amount,
  usd_trade_amount,
  price,
  SUM(trade_count) OVER (ORDER BY block_hour) AS accumulated_trade_count,
  SUM(trade_amount) OVER (ORDER BY block_hour) AS accumulated_trade_amount,
  SUM(usd_trade_amount) OVER (ORDER BY block_hour) AS accumulated_usd_trade_amount,
  AVG(price) OVER (ORDER BY block_hour ROWS BETWEEN 7 PRECEDING AND CURRENT ROW) AS price_ma
FROM 
  op_trades_summary
ORDER BY 
  block_hour;