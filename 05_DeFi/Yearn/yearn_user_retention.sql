/* Description: Calculate user retention ratio for a cohort of users. */

WITH 
  -- Get all users who have interacted with a vault
  cohort_users AS (
    SELECT 
      evt_block_time,
      CONCAT(ytoken, ' ', tag) AS vault,
      t."from" AS wallet,
      (-1)*value/10^(y.decimals) AS value
    FROM 
      erc20."ERC20_evt_Transfer" t
      INNER JOIN yearn."yearn_all_vaults" y ON t."contract_address" = y.contract_address
    WHERE 
      evt_block_time BETWEEN '2022-01-01 00:00:00' AND '2022-06-30 23:59:59'
      AND "to" = '\x0000000000000000000000000000000000000000'
    UNION
    SELECT 
      evt_block_time,
      CONCAT(ytoken, ' ', tag) AS vault,
      t."to" AS wallet,
      value/10^(y.decimals) AS value
    FROM 
      erc20."ERC20_evt_Transfer" t
      INNER JOIN yearn."yearn_all_vaults" y ON t."contract_address" = y.contract_address
    WHERE 
      evt_block_time BETWEEN '2022-01-01 00:00:00' AND '2022-06-30 23:59:59'
      AND "from" = '\x0000000000000000000000000000000000000000'
  ),
  
  -- Get the first active date for each user
  cohort_first_active AS (
    SELECT 
      wallet,
      vault,
      date_trunc('MONTH', MIN(evt_block_time)) AS cohort
    FROM 
      cohort_users
    WHERE 
      wallet NOT IN ('\x0000000000000000000000000000000000000000', '\x0000000000000000000000000000000000000001', '\x000000000000000000000000000000000000dead')
    GROUP BY 1, 2
  ),
  
  -- Get the total amount for each user on each day
  cohort_x AS (
    SELECT 
      date_trunc('MONTH', evt_block_time) AS days_active,
      wallet,
      vault,
      SUM(value) AS amount
    FROM 
      cohort_users
    WHERE 
      wallet NOT IN ('\x0000000000000000000000000000000000000000', '\x0000000000000000000000000000000000000001', '\x000000000000000000000000000000000000dead')
    GROUP BY 1, 2, 3
  ),
  
  -- Generate dummy data for each user
  generateDummyData AS (
    SELECT 
      DISTINCT "generated_date",
      wallet,
      vault,
      0 AS amount
    FROM 
      cohort_x
      CROSS JOIN generate_series('2022-01-01 00:00:00'::DATE, '2022-06-30 23:59:59'::DATE, '1 MONTH') AS "generated_date"
  ),
  
  -- Get the cumulative amount for each user
  cohort_day AS (
    SELECT 
      *,
      CASE WHEN culm_amount > 0 THEN 1 ELSE 0 END AS active_status
    FROM (
      SELECT 
        wallet,
        vault,
        days_active,
        amount,
        SUM(amount) OVER (PARTITION BY wallet, vault ORDER BY days_active ASC) AS culm_amount
      FROM (
        SELECT 
          *
        FROM 
          cohort_x
        UNION ALL
        SELECT 
          "generated_date" AS days_active,
          wallet,
          vault,
          amount
        FROM 
          generateDummyData
      ) x
    ) y
  ),
  
  -- Get the retention ratio for each cohort
  cohort_retention AS (
    SELECT 
      day_rank,
      cohort,
      day_actual,
      active_users,
      active_users / FIRST_VALUE(active_users) OVER (PARTITION BY cohort ORDER BY day_actual ASC) :: FLOAT AS user_retention_ratio
    FROM (
      SELECT 
        RANK() OVER (PARTITION BY cohort ORDER BY day_actual ASC) - 1 AS day_rank,
        cohort,
        day_actual,
        amount,
        active_users
      FROM (
        SELECT 
          to_char(cohort, 'YYYY-MM') AS cohort,
          m.days_active AS day_actual,
          SUM(m.amount) AS amount,
          SUM(active_status) AS active_users
        FROM 
          cohort_first_active c
          JOIN cohort_day m ON c.wallet = m.wallet AND c.vault = m.vault
        GROUP BY 1, 2
      ) x
      WHERE 
        active_users != 0
      ORDER BY 2, 3 ASC
    ) y
  )

SELECT 
  *
FROM 
  cohort_retention
ORDER BY 
  2, 3 ASC;