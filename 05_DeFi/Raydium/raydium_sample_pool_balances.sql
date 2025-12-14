/* Description: Retrieve the latest SOL and USDC balances for two specific addresses within the last 15 minutes. */

WITH sol AS (
  SELECT 
    block_date AS datex,
    post_token_balance AS sol_bal
  FROM `solana`.`account_activity`
  WHERE 
    address = 'DQyrAcCrDXQ7NeoqGgDCZwBvWDcYmFCjSb9JtteuvPpz' 
    AND tx_success = TRUE 
    AND block_time > NOW() - INTERVAL '15 MINUTES'
    AND post_token_balance > 200000
  ORDER BY block_date DESC
  LIMIT 1
),

usdc AS (
  SELECT 
    block_date AS datex,
    post_token_balance AS usdc_bal
  FROM `solana`.`account_activity`
  WHERE 
    address = 'HLmqeL62xR1QoZ1HKKbXRrdN1p3phKpxRMb2VVopvBBz' 
    AND tx_success = TRUE 
    AND block_time > NOW() - INTERVAL '15 MINUTES'
    AND post_token_balance > 20000000
  ORDER BY block_date DESC
  LIMIT 1
)

SELECT 
  sol.datex,
  sol_bal AS SOL_amount,
  usdc_bal AS USDC_amount
FROM sol
LEFT JOIN usdc
ON sol.datex = usdc.datex;