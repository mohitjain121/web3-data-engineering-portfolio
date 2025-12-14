/* Description: Calculate user churn and retention metrics for Uniswap trades. */

WITH
  users AS (
    SELECT
      date_trunc('MONTH', block_time):: DATE AS month,
      date_trunc('DAY', block_time) AS datex,
      trader_a AS address
    FROM
      dex."trades"
    WHERE
      project = 'Uniswap'
    UNION
    SELECT
      date_trunc('MONTH', block_time):: DATE AS month,
      date_trunc('DAY', block_time) AS datex,
      trader_b AS address
    FROM
      dex."trades"
    WHERE
      project = 'Uniswap'
  ),
  mau AS (
    SELECT
      DISTINCT month,
      -- differentiate only by month, but convert it back to a date  '2020-08-01 00:00:00'
      address
    FROM
      users
  ),
  new_user AS (
    SELECT
      MIN(month) AS first_month,
      address
    FROM
      mau
    GROUP BY
      2
  ),
  user_status AS (
    SELECT
      COALESCE(
        mau_now.month,
        DATE_TRUNC('month', mau_prev.month + '45 days':: INTERVAL)
      ) AS month,
      COALESCE(mau_now.address, mau_prev.address) AS user_address,
      CASE
        WHEN nu.address IS NOT NULL THEN 1
        ELSE 0
      END AS if_new,
      -- new user                             √ active
      CASE
        WHEN nu.address IS NULL -- not new user (existing or not yet joined)
        AND mau_prev.address IS NOT NULL -- active last month
        AND mau_now.address IS NULL -- inactive this month
        THEN 1
        ELSE 0
      END AS if_churned,
      -- we lost this user this month         x inactive
      CASE
        WHEN nu.address IS NULL -- not new user (existing or not yet joined)
        AND mau_prev.address IS NOT NULL -- active last month
        AND mau_now.address IS NOT NULL -- active this month
        THEN 1
        ELSE 0
      END AS if_retained,
      -- we retained this user this month     √ active
      CASE
        WHEN nu.address IS NULL -- not new user (existing or not yet joined)
        AND mau_prev.address IS NULL -- inactive last month
        AND mau_now.address IS NOT NULL -- active this month
        THEN 1
        ELSE 0
      END AS if_resurrected,
      -- this user returned this month        √ active
      CASE
        WHEN mau_now.address IS NOT NULL THEN 1
        ELSE 0
      END AS if_active -- active flag for completence check: passed check √
      -- sum(if_new + if_retained + if_resurrected)=sum(if_active) group by month
      -- sum(if_churned + if_active)=count(distinct user_address) group by month
      -- sum(if_new + if_churned + if_retained + if_resurrected)=1 group by month, user_address
    FROM
      mau mau_now
      FULL JOIN mau mau_prev ON mau_prev.month = DATE_TRUNC('month', mau_now.month - '5 days':: INTERVAL)
      AND mau_prev.address = mau_now.address
      LEFT JOIN new_user nu ON nu.address = mau_now.address
      AND nu.first_month = mau_now.month
    WHERE
      COALESCE(
        mau_now.month,
        DATE_TRUNC('month', mau_prev.month + '45 days':: INTERVAL)
      ) < CURRENT_DATE
  ),
  user_status_pivot as (
    SELECT
      month,
      user_address,
      CASE
        WHEN SUM(if_new) = 1 THEN 'New Users'
        WHEN SUM(if_churned) = 1 THEN 'Churned Users'
        WHEN SUM(if_retained) = 1 THEN 'Retained Users'
        WHEN SUM(if_resurrected) = 1 THEN 'Returning Users'
        ELSE NULL
      END AS status
    FROM
      user_status
    GROUP BY
      1,
      2
  ),
  result AS (
    SELECT
      month,
      status,
      COUNT(DISTINCT user_address) AS count
    FROM
      user_status_pivot
    GROUP BY
      1,
      2
  )
SELECT
  month,
  status,
  CASE
    WHEN status = 'Churned Users' THEN -1 * count
    ELSE count
  END AS count
FROM
  result