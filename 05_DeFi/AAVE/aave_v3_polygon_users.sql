/* Description: Calculate daily wallet metrics for Aave V3 Pool events. */

SELECT 
  DISTINCT time
, count("user") AS "Total Wallets"
, count(DISTINCT "user") AS "New Wallets"
, (count("user") - count(DISTINCT "user")) AS "Existing Wallets"

FROM (
  SELECT 
    MIN(date_trunc('day', evt_block_time)) AS time 
  , "user"
  FROM (
    SELECT 
      "user", 
      evt_block_time
    FROM 
      aave_V3."Pool_evt_Borrow"
    UNION 
    SELECT 
      "user", 
      evt_block_time
    FROM 
      aave_v3."Pool_evt_Supply"
    UNION
    SELECT 
      "user", 
      evt_block_time
    FROM 
      aave_v3."Pool_evt_Repay"
    UNION
    SELECT 
      "user", 
      evt_block_time
    FROM 
      aave_v3."Pool_evt_Withdraw"
    UNION
    SELECT 
      "user", 
      evt_block_time
    FROM 
      aave_v3."Pool_evt_LiquidationCall"
  ) AS t1
  GROUP BY 
    t1."user", 
    t1.evt_block_time
) t
GROUP BY 
  t.time
ORDER BY 
  time ASC;