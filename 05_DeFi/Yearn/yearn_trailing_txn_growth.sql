/* Description: Calculate the growth rate of transactions by date period. */

WITH
  txn_volume AS (
    SELECT
      CASE
        WHEN (
          evt_block_time BETWEEN '2022-01-01 00:00:00' AND '2022-06-30 23:59:59'
        ) THEN '2'
        ELSE '1'
      END AS datex,
      COUNT(DISTINCT evt_tx_hash) AS count_txns
    FROM
      (
        SELECT
          evt_block_time,
          evt_tx_hash
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
      evt_block_time
  )
SELECT
  datex,
  SUM(count_txns) AS count_txns,
  (
    SUM(count_txns) - LAG(SUM(count_txns), 1) OVER (
      ORDER BY
        datex
    )
  ) / LAG(SUM(count_txns), 1) OVER (
    ORDER BY
      datex
  ) * 100 AS growth
FROM
  txn_volume
GROUP BY
  1;