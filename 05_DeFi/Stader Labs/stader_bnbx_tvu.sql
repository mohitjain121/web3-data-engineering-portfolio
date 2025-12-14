/* Description: Calculate vault TVL and token TVL for a given contract address. */

WITH
  price AS (
    SELECT
      date_trunc('DAY', minute) AS datex,
      AVG(price) AS price
    FROM
      prices.usd
    WHERE
      contract_address = '\xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c'
    GROUP BY
      1
  ),
  tokens AS (
    SELECT
      datex,
      SUM(SUM(value)) OVER (
        ORDER BY
          datex ASC
      ) AS vault_tvl
    FROM
      (
        SELECT
          date_trunc('DAY', call_block_time) AS datex,
          "_amount" / 1e18 AS value
        FROM
          stader_labs."BnbX_call_mint"
        UNION
        SELECT
          date_trunc('DAY', call_block_time) AS datex,
          (-1) * "_amount" / 1e18 AS value
        FROM
          stader_labs."BnbX_call_burn"
      ) a
    GROUP BY
      1
  )
SELECT
  t.datex,
  t.vault_tvl AS token_tvl,
  t.vault_tvl * p.price AS vault_tvl
FROM
  tokens t
  LEFT JOIN price p ON p.datex = t.datex
ORDER BY
  t.datex DESC