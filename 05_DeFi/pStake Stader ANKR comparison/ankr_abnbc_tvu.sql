/* Description: Calculate token TVL and its value in ABNBC price */
WITH
  price AS (
  SELECT
    datex,
    abnbc_price
  FROM 
    dune_user_generated.abnbc_price),
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
          "amount" / 1e18 AS value
        FROM
          ankr."aBNBc_call_mint"
        UNION
        SELECT
          date_trunc('DAY', call_block_time) AS datex,
          (-1) * "amount" / 1e18 AS value
        FROM
          ankr."aBNBc_call_burn"
      ) a
    GROUP BY
      1
  )
SELECT
  t.datex,
  t.vault_tvl AS token_tvl,
  t.vault_tvl * p.abnbc_price AS vault_value_in_abnbc
FROM
  tokens t
  LEFT JOIN price p ON p.datex = t.datex
ORDER BY
  t.datex DESC