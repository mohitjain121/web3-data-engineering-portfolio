/* Description: Calculate daily unique and new users from Solana transactions */
WITH 
  u1 AS (
    SELECT 
      MIN(`block_date`) AS datex, 
      account_keys[0] AS unique_users
    FROM 
      `solana`.`transactions`
    WHERE 
      array_contains(account_keys, '675kPX9MHTjS2zt1qfr1NYHuzeLXfQM9H24wFSUt1Mp8')
      AND `block_date` > CURRENT_DATE - INTERVAL '1 MONTH'
  ),
  
  u2 AS (
    SELECT 
      datex, 
      COUNT(unique_users) AS users_new
    FROM 
      u1
    GROUP BY 
      1
  ),
  
  u3 AS (
    SELECT 
      `block_date` AS datex, 
      COUNT(DISTINCT account_keys[0]) AS unique_users
    FROM 
      `solana`.`transactions`
    WHERE 
      array_contains(account_keys, '675kPX9MHTjS2zt1qfr1NYHuzeLXfQM9H24wFSUt1Mp8')
      AND `block_date` > CURRENT_DATE - INTERVAL '1 MONTH'
    GROUP BY 
      1
  )
  
SELECT 
  u2.datex AS `DAY`,
  u3.unique_users AS `Unique Users DAILY`, 
  u2.users_new AS `New Users DAILY`, 
  (u3.unique_users - u2.users_new) AS `Repeat Users DAILY`
FROM 
  u2
  LEFT JOIN 
  u3 ON u2.datex = u3.datex
GROUP BY 
  1, 2, 3, 4
ORDER BY 
  1 DESC;