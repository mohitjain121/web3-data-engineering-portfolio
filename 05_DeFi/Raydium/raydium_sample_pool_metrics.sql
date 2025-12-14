/* Description: Calculate net token balances and volumes for two addresses over the last 24 hours. */
WITH 
  sol AS (
    SELECT 
      SUM(CASE WHEN token_balance_change > 0 THEN token_balance_change ELSE NULL END) AS sol_added,
      SUM(CASE WHEN token_balance_change < 0 THEN token_balance_change ELSE NULL END) AS sol_removed,
      SUM(ABS(token_balance_change)) AS sol_volume
    FROM `solana`.`account_activity`
    WHERE 
      `address` = 'DQyrAcCrDXQ7NeoqGgDCZwBvWDcYmFCjSb9JtteuvPpz'
      AND token_balance_change < 200000
      AND token_balance_change > -200000
      AND block_time > NOW() - INTERVAL '24 HOURS'
      AND tx_success = TRUE
  ),
  usdc AS (
    SELECT 
      SUM(CASE WHEN token_balance_change > 0 THEN token_balance_change ELSE NULL END) AS usdc_added,
      SUM(CASE WHEN token_balance_change < 0 THEN token_balance_change ELSE NULL END) AS usdc_removed,
      SUM(ABS(token_balance_change)) AS usdc_volume
    FROM `solana`.`account_activity`
    WHERE 
      `address` = 'HLmqeL62xR1QoZ1HKKbXRrdN1p3phKpxRMb2VVopvBBz'
      AND token_balance_change < 20000000
      AND token_balance_change > -20000000
      AND block_time > NOW() - INTERVAL '24 HOURS'
      AND tx_success = TRUE
  )
SELECT 
  sol_added,
  sol_removed,
  (sol_added + sol_removed) AS net_sol,
  usdc_added,
  usdc_removed,
  (usdc_added + usdc_removed) AS net_usdc,
  sol_volume, 
  usdc_volume
FROM sol, usdc
WHERE sol_added IS NOT NULL AND usdc_added IS NOT NULL;