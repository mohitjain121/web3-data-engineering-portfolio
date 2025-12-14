/* Description: Calculate user volume growth over time */
WITH 
users AS (
  SELECT 
    block_time, 
    `from` AS unique_user
  FROM arbitrum.transactions
  UNION
  SELECT
    block_time, 
    `to` AS unique_user
  FROM arbitrum.transactions),

user_volume AS (
  SELECT 
    CASE 
      WHEN (block_time > NOW() - INTERVAL '6 MONTHS') THEN '2' 
      ELSE '1'
    END AS datex,
    COUNT(DISTINCT unique_user) AS count_users
  FROM users
  WHERE block_time > NOW() - INTERVAL '12 MONTHS'
  GROUP BY 1)

SELECT
  datex,
  SUM(count_users) AS count_txns,
  (SUM(count_users) - LAG(SUM(count_users), 1) OVER (ORDER BY datex)) / 
  LAG(SUM(count_users), 1) OVER (ORDER BY datex) * 100 AS growth
FROM user_volume
GROUP BY 1;