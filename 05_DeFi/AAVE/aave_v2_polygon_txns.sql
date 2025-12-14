/* Description: Aggregate Aave V2 transactions by date and action. */

WITH 
  aave_v2_supply AS (
    SELECT 
      "evt_block_time" AS "date",
      'supply' AS "action",
      "user" AS "user"
    FROM 
      aave_v2."LendingPool_evt_Deposit"
  ),
  
  aave_v2_withdraw AS (
    SELECT 
      "evt_block_time" AS "date",
      'withdraw' AS "action",
      "user" AS "user"
    FROM 
      aave_v2."LendingPool_evt_Withdraw"
  ),
  
  aave_v2_borrow AS (
    SELECT 
      "evt_block_time" AS "date",
      'borrow' AS "action",
      "user" AS "user"
    FROM 
      aave_v2."LendingPool_evt_Borrow"
  ),
  
  aave_v2_repay AS (
    SELECT 
      "evt_block_time" AS "date",
      'repay' AS "action",
      "user" AS "user"
    FROM 
      aave_v2."LendingPool_evt_Repay"
  ),
  
  aave_v2_liquidation AS (
    SELECT 
      "evt_block_time" AS "date",
      'liquidation' AS "action",
      "liquidator" AS "user"
    FROM 
      aave_v2."LendingPool_evt_LiquidationCall"
  ),
  
  getAllV2Transaction AS (
    SELECT * FROM aave_v2_supply
    UNION ALL
    SELECT * FROM aave_v2_withdraw
    UNION ALL
    SELECT * FROM aave_v2_borrow
    UNION ALL
    SELECT * FROM aave_v2_repay
    UNION ALL
    SELECT * FROM aave_v2_liquidation
  )

SELECT 
  "date",
  SUM(CASE WHEN "action" = 'withdraw' THEN "txn_count" END) OVER (ORDER BY "date") AS "withdraw",
  SUM(CASE WHEN "action" = 'liquidation' THEN "txn_count" END) OVER (ORDER BY "date") AS "liquidation",
  SUM(CASE WHEN "action" = 'repay' THEN "txn_count" END) OVER (ORDER BY "date") AS "repay",
  SUM(CASE WHEN "action" = 'supply' THEN "txn_count" END) OVER (ORDER BY "date") AS "supply",
  SUM(CASE WHEN "action" = 'borrow' THEN "txn_count" END) OVER (ORDER BY "date") AS "borrow",
  SUM("txn_count") OVER (ORDER BY "date") AS "total_transaction"
FROM (
  SELECT 
    date_trunc('day',"evt_block_time") AS "date",
    "action",
    COUNT(*) AS "txn_count"
  FROM 
    getAllV2Transaction
  GROUP BY 
    1, 2
) x
GROUP BY 
  1
ORDER BY 
  2 DESC;