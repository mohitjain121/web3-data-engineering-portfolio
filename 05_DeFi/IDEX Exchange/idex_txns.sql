/* Description: Daily trade count aggregation for the last {{days}} days */
SELECT 
  datex, 
  SUM(count_trades) as num_trades 
FROM (
  SELECT 
    date_trunc('DAY', "evt_block_time") AS datex, 
    COUNT(1) as count_trades 
  FROM idex_v3."Exchange_v3_1_evt_OrderBookTradeExecuted" 
  WHERE "evt_block_time" >= CURRENT_DATE - INTERVAL '{{days}}' DAY 
  GROUP BY datex
) AS order_book_trades 
UNION 
SELECT 
  datex, 
  COUNT(1) as count_trades 
FROM (
  SELECT 
    date_trunc('DAY', "evt_block_time") AS datex 
  FROM idex_v3."Exchange_v3_1_evt_PoolTradeExecuted" 
  WHERE "evt_block_time" >= CURRENT_DATE - INTERVAL '{{days}}' DAY 
  GROUP BY datex
) AS pool_trades 
UNION 
SELECT 
  datex, 
  COUNT(1) as count_trades 
FROM (
  SELECT 
    date_trunc('DAY', "evt_block_time") AS datex 
  FROM idex_v3."Exchange_v3_1_evt_HybridTradeExecuted" 
  WHERE "evt_block_time" >= CURRENT_DATE - INTERVAL '{{days}}' DAY 
  GROUP BY datex
) AS hybrid_trades 
) AS trades_daily 
GROUP BY datex 
ORDER BY datex DESC 
LIMIT {{days}}