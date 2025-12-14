/* Description: Calculate active, new, and existing borrowers by day. */
SELECT 
  time AS datex, 
  COUNT("user") AS "Active Borrowers", 
  COUNT(DISTINCT "user") AS "New Borrowers", 
  COUNT("user") - COUNT(DISTINCT "user") AS "Existing Borrowers"
FROM 
  (
    SELECT 
      MIN(date_trunc('DAY', evt_block_time)) AS time, 
      "user"
    FROM 
      aave_v3."Pool_evt_Borrow"
    GROUP BY 
      2, 
      evt_block_time
  ) x
GROUP BY 
  1