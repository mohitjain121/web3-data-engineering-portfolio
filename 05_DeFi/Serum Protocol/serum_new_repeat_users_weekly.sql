/* Description: Weekly user metrics for Serum DEX transactions */
SELECT 
  y.datex AS `week`, 
  unique_users AS `unique_users_weekly`, 
  users_new AS `new_users_weekly`, 
  (unique_users - users_new) AS `repeat_users_weekly`
FROM (
  SELECT 
    datex, 
    COUNT(unique_users) AS users_new
  FROM (
    SELECT 
      MIN(date_trunc('WEEK', block_date)) AS datex, 
      account_keys[0] AS unique_users
    FROM `solana`.`transactions`
    WHERE 
      (array_contains(account_keys, '9xQeWvG816bUx9EPjHmaT23yvVM2ZWbrrpZb9PusVFin') 
        OR array_contains(account_keys, 'EUqojwWA2rd19FZrzeBncJsm38Jm1hEhE3zsmX3bRc2o') 
        OR array_contains(account_keys, 'BJ3jrUzddfuSrZHXSCxMUUQsjKEyLmuuyZebkcaFp2fg')
      )
      AND block_date > CURRENT_DATE - INTERVAL '6 MONTHS'
    GROUP BY 2
    ORDER BY 2
  ) x
  GROUP BY 1
) y
LEFT JOIN (
  SELECT 
    date_trunc('WEEK', block_date) AS datex, 
    COUNT(DISTINCT account_keys[0]) AS unique_users
  FROM `solana`.`transactions`
  WHERE 
    (array_contains(account_keys, '9xQeWvG816bUx9EPjHmaT23yvVM2ZWbrrpZb9PusVFin') 
      OR array_contains(account_keys, 'EUqojwWA2rd19FZrzeBncJsm38Jm1hEhE3zsmX3bRc2o') 
      OR array_contains(account_keys, 'BJ3jrUzddfuSrZHXSCxMUUQsjKEyLmuuyZebkcaFp2fg')
    )
    AND block_date > CURRENT_DATE - INTERVAL '6 MONTHS'
  GROUP BY datex
  ORDER BY datex
) z ON z.datex = y.datex
ORDER BY y.datex DESC;