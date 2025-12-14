/* Description: Calculate daily success and failure rates for specified Solana addresses. */

WITH 
  -- Daily success transactions
  success AS (
    SELECT 
      date_trunc('DAY', block_time) AS datex,
      COUNT (tx_id) AS success_txns
    FROM 
      `solana`.`account_activity`
    WHERE 
      (address = '9xQeWvG816bUx9EPjHmaT23yvVM2ZWbrrpZb9PusVFin'
        OR address = 'EUqojwWA2rd19FZrzeBncJsm38Jm1hEhE3zsmX3bRc2o'
        OR address = 'BJ3jrUzddfuSrZHXSCxMUUQsjKEyLmuuyZebkcaFp2fg')
      AND tx_success = TRUE
    GROUP BY 1
  ),
  
  -- Daily failure transactions
  failure AS (
    SELECT 
      date_trunc('DAY', block_time) AS datex,
      COUNT (tx_id) AS failed_txns
    FROM 
      `solana`.`account_activity`
    WHERE 
      (address = '9xQeWvG816bUx9EPjHmaT23yvVM2ZWbrrpZb9PusVFin'
        OR address = 'EUqojwWA2rd19FZrzeBncJsm38Jm1hEhE3zsmX3bRc2o'
        OR address = 'BJ3jrUzddfuSrZHXSCxMUUQsjKEyLmuuyZebkcaFp2fg')
      AND tx_success = FALSE
    GROUP BY 1
  )

SELECT 
  success.datex,
  success_txns,
  failed_txns,
  (failed_txns / (success_txns + failed_txns)) * 100 AS failure_rate
FROM 
  success
  FULL JOIN failure ON success.datex = failure.datex
GROUP BY 
  1, 2, 3, 4
ORDER BY 
  1 DESC;