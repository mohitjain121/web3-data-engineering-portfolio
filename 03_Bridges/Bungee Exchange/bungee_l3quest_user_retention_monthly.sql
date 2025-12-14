/*
Description: Calculate average user retention rates for each month after the first transaction.
*/

WITH
  events AS (
    SELECT
      evt_block_time AS transaction_date,
      sender
    FROM
      query_{{txns_table_query}}
    WHERE
      sender IN (SELECT address FROM query_{{wallets_query}})
  ),
  first_transaction AS (
    SELECT
      sender,
      DATE_TRUNC('MONTH', transaction_date) AS month,
      DATE_TRUNC('MONTH', MIN(transaction_date)) AS first_transaction_month
    FROM
      events
    GROUP BY
      sender,
      DATE_TRUNC('MONTH', transaction_date)
  ),
  cohorts AS (
    SELECT
      first_transaction.sender,
      first_transaction.first_transaction_month,
      events.transaction_date
    FROM
      events
      JOIN first_transaction ON events.sender = first_transaction.sender
    WHERE
      events.transaction_date >= first_transaction.first_transaction_month
  ),
  cohorts_grouped AS (
    SELECT
      first_transaction_month,
      DATE_DIFF('MONTH', first_transaction_month, transaction_date) AS mon_diff,
      COUNT(DISTINCT sender) AS retained_users
    FROM
      cohorts
    GROUP BY
      first_transaction_month,
      DATE_DIFF('MONTH', first_transaction_month, transaction_date)
  ),
  total_users_per_cohort AS (
    SELECT
      month,
      COUNT(DISTINCT sender) AS total_users
    FROM
      first_transaction
    GROUP BY
      month
  )
SELECT
  'Average Retention' AS retention,
  AVG(CASE WHEN month_diff = 0 THEN retention_rate END) AS "<1 Month",
  AVG(CASE WHEN month_diff = 1 THEN retention_rate END) AS "1st Month",
  AVG(CASE WHEN month_diff = 2 THEN retention_rate END) AS "2nd Month",
  AVG(CASE WHEN month_diff = 3 THEN retention_rate END) AS "3rd Month",
  AVG(CASE WHEN month_diff = 4 THEN retention_rate END) AS "4th Month"
FROM
  (
    SELECT
      cohorts_grouped.first_transaction_month AS transaction_month,
      cohorts_grouped.mon_diff AS month_diff,
      total_users_per_cohort.total_users AS total_users,
      cohorts_grouped.retained_users AS retained_users,
      100.0 * cohorts_grouped.retained_users / total_users_per_cohort.total_users AS retention_rate
    FROM
      cohorts_grouped
      JOIN total_users_per_cohort ON cohorts_grouped.first_transaction_month = total_users_per_cohort.month
  ) sub
GROUP BY
  1