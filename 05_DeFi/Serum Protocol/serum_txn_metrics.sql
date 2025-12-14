/* Description: Calculate the failure rate of transactions for Serum DEX versions. */
WITH 
  success AS (
    SELECT 
      COUNT(tx_id) AS success_txns
    FROM 
      `solana`.`account_activity`
    WHERE 
      (address = '9xQeWvG816bUx9EPjHmaT23yvVM2ZWbrrpZb9PusVFin'  -- Serum DEX V3
       OR address = 'EUqojwWA2rd19FZrzeBncJsm38Jm1hEhE3zsmX3bRc2o'  -- Serum DEX V2
       OR address = 'BJ3jrUzddfuSrZHXSCxMUUQsjKEyLmuuyZebkcaFp2fg')  -- Serum DEX V1
      AND tx_success = TRUE
  ),
  failure AS (
    SELECT 
      COUNT(tx_id) AS failed_txns
    FROM 
      `solana`.`account_activity`
    WHERE 
      (address = '9xQeWvG816bUx9EPjHmaT23yvVM2ZWbrrpZb9PusVFin'  -- Serum DEX V3
       OR address = 'EUqojwWA2rd19FZrzeBncJsm38Jm1hEhE3zsmX3bRc2o'  -- Serum DEX V2
       OR address = 'BJ3jrUzddfuSrZHXSCxMUUQsjKEyLmuuyZebkcaFp2fg')  -- Serum DEX V1
      AND tx_success = FALSE
  )
SELECT 
  success_txns,
  failed_txns,
  (failed_txns / (success_txns + failed_txns)) * 100 AS failure_rate
FROM 
  success,
  failure