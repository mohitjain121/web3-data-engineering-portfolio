/* Description: Calculate daily user metrics for ytoken transfers. */

WITH 
  ytokens AS (
    SELECT 
      *
    FROM 
      yearn."yearn_all_vaults" y
  ),
  
  u1 AS (
    SELECT 
      MIN(date_trunc('DAY', evt_block_time)) AS datex, 
      t."from" AS unique_users -- wallets sending ytokens
    FROM 
      erc20."ERC20_evt_Transfer" t
      INNER JOIN ytokens y ON t."contract_address" = y.contract_address
    GROUP BY 2
    UNION
    SELECT 
      MIN(date_trunc('DAY', evt_block_time)) AS datex, 
      t."to" AS unique_users -- addresses receiving ytokens
    FROM 
      erc20."ERC20_evt_Transfer" t
      INNER JOIN ytokens y ON t."contract_address" = y.contract_address
    GROUP BY 2
  ),
  
  u2 AS (
    SELECT 
      datex, 
      COUNT(unique_users) AS users_new 
    FROM 
      u1
    GROUP BY 1
  ),
  
  u3 AS (
    SELECT 
      datex, 
      COUNT(DISTINCT unique_users) AS unique_users 
    FROM 
      (
        SELECT 
          date_trunc('DAY', evt_block_time) AS datex, 
          t."from" AS unique_users -- wallets sending ytokens 
        FROM 
          erc20."ERC20_evt_Transfer" t
          INNER JOIN ytokens y ON t."contract_address" = y.contract_address
        GROUP BY 1, 2
        UNION
        SELECT 
          date_trunc('DAY', evt_block_time) AS datex, 
          t."to" AS unique_users -- wallets receiving ytokens 
        FROM 
          erc20."ERC20_evt_Transfer" t
          INNER JOIN ytokens y ON t."contract_address" = y.contract_address
        GROUP BY 1, 2
      ) x
    GROUP BY 1
  )
  
SELECT 
  u2.datex AS "DAY",
  u3.unique_users AS "Total Users DAILY", 
  u2.users_new AS "New Users DAILY", 
  (u3.unique_users - u2.users_new) AS "Repeat Users DAILY"
FROM 
  u2
  LEFT JOIN u3 ON u2.datex = u3.datex
GROUP BY 1, 2, 3, 4
ORDER BY 1 DESC;