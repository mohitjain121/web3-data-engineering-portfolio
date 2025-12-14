/* Description: Calculate Solana transaction volume growth over time */
WITH txn_volume AS (
  SELECT 
    -- Determine if transaction is within the last 6 months
    CASE 
      WHEN (block_time > NOW() - INTERVAL '6 MONTHS') THEN  '2' 
      ELSE '1'
    END AS datex,
    COUNT (DISTINCT tx_id) AS count_txns
  FROM `solana`.`account_activity`
  WHERE 
    address = '9xQeWvG816bUx9EPjHmaT23yvVM2ZWbrrpZb9PusVFin'
    AND block_time > NOW() - INTERVAL '12 MONTHS'
  GROUP BY 1
)
SELECT
  datex,
  SUM(count_txns) AS count_txns,
  -- Calculate growth rate
  (SUM(count_txns) - LAG(SUM(count_txns), 1) OVER (ORDER BY datex)) / 
  LAG(SUM(count_txns), 1) OVER (ORDER BY datex) * 100 AS growth
FROM txn_volume
GROUP BY 1;