/* Description: Calculate user growth based on ytoken transactions. */
WITH
  users AS (
    SELECT
      CASE
        WHEN (
          evt_block_time BETWEEN '2022-01-01 00:00:00' AND '2022-06-30 23:59:59'
        ) THEN '2'
        ELSE '1'
      END AS datex,
      COUNT(DISTINCT user_address) AS num_users
    FROM
      (
        SELECT
          evt_block_time,
          t."from" AS user_address -- wallets sending ytokens
        FROM
          erc20."ERC20_evt_Transfer" t
        WHERE
          t.contract_address IN (
            SELECT
              contract_address
            FROM
              yearn."yearn_all_vaults"
          )
        UNION
        SELECT
          evt_block_time,
          t."to" AS user_address -- addresses receiving ytokens
        FROM
          erc20."ERC20_evt_Transfer" t
        WHERE
          t.contract_address IN (
            SELECT
              contract_address
            FROM
              yearn."yearn_all_vaults"
          )
      ) x
    WHERE
      evt_block_time BETWEEN '2021-07-01 00:00:00' AND '2022-06-30 23:59:59'
    GROUP BY
      1
  )
SELECT
  datex,
  SUM(num_users) AS count_users,
  (
    SUM(num_users) - LAG(SUM(num_users), 1) OVER (
      ORDER BY
        datex
    )
  ) / LAG(SUM(num_users), 1) OVER (
    ORDER BY
      datex
  ) * 100 AS growth
FROM
  users
GROUP BY
  1