/* Description: Calculate active, new, and existing depositors for AAVE v3 pool */
SELECT 
  time AS datex, 
  COUNT("user") AS "Active Depositors", 
  COUNT(DISTINCT "user") AS "New Depositors", 
  COUNT("user") - COUNT(DISTINCT "user") AS "Existing Depositors"
FROM 
  (
    SELECT 
      MIN(date_trunc('DAY', evt_block_time)) AS time, 
      "user"
    FROM 
      aave_v3."Pool_evt_Supply"
    GROUP BY 
      2, 
      evt_block_time
  ) x
GROUP BY 
  1