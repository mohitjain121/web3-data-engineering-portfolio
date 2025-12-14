/* Description: Bucket transactions by user based on transaction count */
WITH
  users AS (
  SELECT 
    `from` AS user,
    COUNT(DISTINCT `hash`) AS num_txns
  FROM 
    arbitrum.transactions
  GROUP BY 
    1)
SELECT 
  'bucket' AS bucket,
  SUM(CASE WHEN num_txns < 3 THEN 1 ELSE 0 END) AS `0 - 2`,
  SUM(CASE WHEN num_txns >= 3 AND num_txns < 6 THEN 1 ELSE 0 END) AS `3 - 5`,
  SUM(CASE WHEN num_txns >= 6 AND num_txns < 11 THEN 1 ELSE 0 END) AS `6 - 10`,
  SUM(CASE WHEN num_txns >= 11 AND num_txns < 101 THEN 1 ELSE 0 END) AS `11 - 100`,
  SUM(CASE WHEN num_txns >= 101 AND num_txns < 501 THEN 1 ELSE 0 END) AS `101 - 500`,
  SUM(CASE WHEN num_txns >= 501 AND num_txns < 5001 THEN 1 ELSE 0 END) AS `501 - 5000`,
  SUM(CASE WHEN num_txns >= 5001 THEN 1 ELSE 0 END) AS `>5000`
FROM 
  users