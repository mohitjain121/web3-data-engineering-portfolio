/* Description: Calculate daily unique and repeat users from Solana transactions. */
WITH 
  u1 AS (
    SELECT 
      MIN(`block_date`) AS datex,
      account_keys[0] AS unique_users
    FROM 
      `solana`.`transactions`
    WHERE 
      array_contains(account_keys, 'FarmqiPv5eAj3j1GMdMCMUGXqPUvmquZtMy86QH6rzhG')
      AND success == true
      AND block_time >= '2022-07-01'
    GROUP BY 
      2
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
      array_contains(account_keys, 'FarmqiPv5eAj3j1GMdMCMUGXqPUvmquZtMy86QH6rzhG')
      AND success == true
      AND block_time >= '2022-07-01'
    GROUP BY 
      1
  )
  
SELECT 
  u2.datex AS `day`,
  u3.unique_users AS `unique_users_daily`, 
  u2.users_new AS `new_users_daily`, 
  (u3.unique_users - u2.users_new) AS `repeat_users_daily`
FROM 
  u2
  LEFT JOIN 
  u3 ON u2.datex = u3.datex