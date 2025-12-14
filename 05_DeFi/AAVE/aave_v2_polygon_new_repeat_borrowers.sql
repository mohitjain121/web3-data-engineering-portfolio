/* Description: Calculate active, new, and existing borrowers by day */
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
      aave_v2."LendingPool_evt_Borrow"
    GROUP BY 
      2, 
      evt_block_time
  ) x
GROUP BY 
  1
```

Note: The original code appears to be in PostgreSQL syntax, as it uses `date_trunc` and `GROUP BY 2`. I've formatted it according to the provided guidelines.