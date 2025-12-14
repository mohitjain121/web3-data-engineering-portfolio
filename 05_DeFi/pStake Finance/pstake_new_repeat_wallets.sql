/* Description: Calculate weekly user metrics for a set of contracts. */

WITH 
  -- Filter transfers by contract addresses
  pstake AS (
    SELECT 
      *
    FROM 
      erc20."ERC20_evt_Transfer"
    WHERE 
      contract_address IN (
        '\x44017598f2AF1bD733F9D87b5017b4E7c1B28DDE',  -- Atom
        '\x45e007750Cc74B1D2b4DD7072230278d9602C499',   -- XPR
        '\x2C5Bcad9Ade17428874855913Def0A02D8bE2324'   -- ETH
      )
  ),

  -- Get unique users for each week
  u1 AS (
    SELECT 
      MIN(date_trunc('WEEK', evt_block_time)) AS datex, 
      p."from" AS unique_users 
    FROM 
      pstake p
    GROUP BY 2
    UNION
    SELECT 
      MIN(date_trunc('WEEK', evt_block_time)) AS datex, 
      p."to" AS unique_users
    FROM 
      pstake p
    GROUP BY 2
  ),

  -- Count new users for each week
  u2 AS (
    SELECT 
      datex, 
      COUNT(unique_users) AS users_new 
    FROM 
      u1
    GROUP BY 1
  ),

  -- Count unique users for each week
  u3 AS (
    SELECT 
      datex, 
      COUNT(DISTINCT unique_users) AS unique_users 
    FROM 
      (
        SELECT 
          date_trunc('WEEK', evt_block_time) AS datex, 
          p."from" AS unique_users 
        FROM 
          pstake p
        GROUP BY 1, 2
        UNION
        SELECT 
          date_trunc('WEEK', evt_block_time) AS datex, 
          p."to" AS unique_users
        FROM 
          pstake p
        GROUP BY 1, 2
      ) x
    GROUP BY 1
  )

SELECT 
  u2.datex AS "Week",
  unique_users AS "Total Users Weekly", 
  users_new AS "New Users Weekly", 
  (unique_users - users_new) AS "Repeat Users Weekly"
FROM 
  u2 
  LEFT JOIN 
  u3 ON u2.datex = u3.datex
GROUP BY 1, 2, 3, 4
ORDER BY 1 DESC;