/* Description: Aggregate Aave V3 transactions by date and action. */

WITH 
  -- Extract supply, withdraw, borrow, repay, and liquidation events from Aave V3 logs.
  aave_v3_supply AS (
    SELECT 
      "evt_block_time" AS "date",
      'supply' AS "action",
      "user" AS "user"
    FROM 
      aave_v3."Pool_evt_Supply"
  ),
  
  aave_v3_withdraw AS (
    SELECT 
      "evt_block_time" AS "date",
      'withdraw' AS "action",
      "user" AS "user"
    FROM 
      aave_v3."Pool_evt_Withdraw"
  ),
  
  aave_v3_borrow AS (
    SELECT 
      "evt_block_time" AS "date",
      'borrow' AS "action",
      "user" AS "user"
    FROM 
      aave_v3."Pool_evt_Borrow"
  ),
  
  aave_v3_repay AS (
    SELECT 
      "evt_block_time" AS "date",
      'repay' AS "action",
      "user" AS "user"
    FROM 
      aave_v3."Pool_evt_Repay"
  ),
  
  aave_v3_liquidation AS (
    SELECT 
      "evt_block_time" AS "date",
      'liquidation' AS "action",
      "user" AS "user"
    FROM 
      aave_v3."Pool_evt_LiquidationCall"
  ),
  
  -- Combine all events into a single table.
  getAllV3Transaction AS (
    SELECT * FROM aave_v3_supply
    UNION ALL
    SELECT * FROM aave_v3_withdraw
    UNION ALL
    SELECT * FROM aave_v3_borrow
    UNION ALL
    SELECT * FROM aave_v3_repay
    UNION ALL
    SELECT * FROM aave_v3_liquidation
  ),
  
  -- Group events by date and action, and count the number of transactions.
  transaction_counts AS (
    SELECT 
      date_trunc('day',"evt_block_time") AS "date",
      "action",
      COUNT(*) AS "txn_count"
    FROM 
      getAllV3Transaction
    GROUP BY 
      1, 2
  )
  
-- Calculate the cumulative sum of transactions by date and action.
SELECT 
  "date",
  SUM(CASE WHEN "action" = 'withdraw' THEN "txn_count" END) OVER (ORDER BY "date") AS "withdraw",
  SUM(CASE WHEN "action" = 'liquidation' THEN "txn_count" END) OVER (ORDER BY "date") AS "liquidation",
  SUM(CASE WHEN "action" = 'repay' THEN "txn_count" END) OVER (ORDER BY "date") AS "repay",
  SUM(CASE WHEN "action" = 'supply' THEN "txn_count" END) OVER (ORDER BY "date") AS "supply",
  SUM(CASE WHEN "action" = 'borrow' THEN "txn_count" END) OVER (ORDER BY "date") AS "borrow",
  SUM("txn_count") OVER (ORDER BY "date") AS "total_transaction"
FROM 
  transaction_counts
ORDER BY 
  1 DESC;