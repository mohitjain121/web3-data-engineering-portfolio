/* Description: Calculate weekly user metrics from Arbitrum transactions. */

WITH 
  -- Extract unique users from transactions
  users AS (
    SELECT 
      block_time, 
      `from` AS unique_user
    FROM arbitrum.transactions
    UNION
    SELECT
      block_time, 
      `to` AS unique_user
    FROM arbitrum.transactions
  ),
  
  -- Group users by week and count unique users
  u1 AS (
    SELECT 
      MIN(date_trunc('WEEK', block_time)) AS datex, 
      unique_user AS unique_users
    FROM users
    GROUP BY 2
  ),
  
  -- Count new users per week
  u2 AS (
    SELECT 
      datex, 
      COUNT(unique_users) AS users_new
    FROM u1
    GROUP BY 1
  ),
  
  -- Count unique users per week
  u3 AS (
    SELECT 
      date_trunc('WEEK', block_time) AS datex, 
      COUNT(DISTINCT unique_user) AS unique_users
    FROM users
    GROUP BY 1
  )
  
SELECT 
  u2.datex AS datex, 
  u3.unique_users AS unique_users, 
  u2.users_new AS new_users, 
  (u3.unique_users - u2.users_new) AS repeat_users,
  SUM(u2.users_new) OVER (ORDER BY u2.datex ASC) AS cumulative_users
FROM u2
LEFT JOIN u3 ON u2.datex = u3.datex
ORDER BY 1 DESC;