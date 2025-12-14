/* Description: Count total users who have interacted with FarmqiPv5eAj3j1GMdMCMUGXqPUvmquZtMy86QH6rzhG and Stake11111111111111111111111111111111111111 */
WITH 
total_users AS (
  SELECT 
    DISTINCT account_keys[0] AS users
  FROM 
    solana.transactions
  WHERE 
    array_contains(
      account_keys,
      'FarmqiPv5eAj3j1GMdMCMUGXqPUvmquZtMy86QH6rzhG'
    )
    AND success == true
    AND block_time >= '2022-07-01'
)
SELECT 
  COUNT(users)
FROM 
  total_users
WHERE 
  users IN (
    SELECT 
      DISTINCT account_keys[0] 
    FROM 
      solana.transactions
    WHERE 
      array_contains(
        account_keys,
        'Stake11111111111111111111111111111111111111'
      )
      AND success == true
  )