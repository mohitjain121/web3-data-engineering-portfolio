/* Description: Calculate Solana transaction volume growth over the last 12 months. */

WITH txn_volume AS (
  SELECT 
    CASE 
      WHEN (block_date > NOW() - INTERVAL '6 MONTHS') THEN  '2' 
      ELSE '1'
    END AS week,
    COUNT (DISTINCT tx_id) AS count_txns
  FROM `solana`.`account_activity`
  WHERE address = '9xQeWvG816bUx9EPjHmaT23yvVM2ZWbrrpZb9PusVFin' 
    AND block_date > NOW() - INTERVAL '12 MONTHS'
  GROUP BY 1
)
SELECT
  week,
  SUM(count_txns) AS count_txns,
  (SUM(count_txns) - LAG(SUM(count_txns), 1) OVER (ORDER BY week)) / 
  LAG(SUM(count_txns), 1) OVER (ORDER BY week) * 100 AS growth
FROM txn_volume
GROUP BY 1;