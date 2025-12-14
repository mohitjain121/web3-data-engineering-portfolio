/* Description: Calculate token TVL and cumulative transactions for a specific token. */

WITH
  wbnb_price AS (
    SELECT
      date_trunc('DAY', minute) AS datex,
      AVG(price) * 2 AS wbnb_price
    FROM
      prices."usd"
    WHERE
      symbol = 'WBNB' -- wbnb
    GROUP BY
      1
  ),
  tokens AS (
    SELECT
      datex,
      SUM(SUM(value)) OVER (
        ORDER BY
          datex ASC
      ) AS token_tvl,
      SUM(COUNT(DISTINCT evt_tx_hash)) OVER (
        ORDER BY
          datex ASC
      ) AS cumu_txns
    FROM
      (
        SELECT
          DISTINCT date_trunc('DAY', evt_block_time) AS datex,
          value / 1e18 AS value,
          evt_tx_hash AS evt_tx_hash
        FROM
          pancakeswap_v2."PancakePair_evt_Transfer"
        WHERE
          "contract_address" = '\xaa2527ff1893e0d40d4a454623d362b79e8bb7f1'
          AND "from" = '\xdfced03b6c764d029b4536e86903e6fa8c47294d'
          AND "to" = '\xa5f8c5dbd5f286960b9d90548680ae5ebff07652'
        UNION
        SELECT
          DISTINCT date_trunc('DAY', evt_block_time) AS datex,
          (-1) * value / 1e18 AS value,
          evt_tx_hash AS evt_tx_hash
        FROM
          pancakeswap_v2."PancakePair_evt_Transfer"
        WHERE
          "contract_address" = '\xaa2527ff1893e0d40d4a454623d362b79e8bb7f1'
          AND "to" = '\xdfced03b6c764d029b4536e86903e6fa8c47294d'
          AND "from" = '\xa5f8c5dbd5f286960b9d90548680ae5ebff07652'
      ) x
    GROUP BY
      1
  )
SELECT
  t.datex,
  token_tvl,
  token_tvl * wbnb_price AS dollar_tvl,
  cumu_txns
FROM
  tokens t
  LEFT JOIN wbnb_price p ON p.datex = t.datex
ORDER BY
  1 DESC;