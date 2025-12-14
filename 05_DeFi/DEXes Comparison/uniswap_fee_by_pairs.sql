/* Description: Calculate top 15 protocol revenue pairs for Uniswap over the last 30 days */
WITH
  price AS (
    SELECT
      date_trunc('DAY', minute) AS datex,
      contract_address,
      AVG(price) AS price
    FROM
      prices.usd
    WHERE
      minute > NOW() - '30 DAYS':: INTERVAL
    GROUP BY
      1,
      2
  ),
  volume AS (
    SELECT
      date_trunc('DAY', block_time) AS datex,
      CONCAT(token_a_symbol, '-', token_b_symbol) AS pair,
      SUM(
        CASE
          WHEN token_a_address = a.contract_address THEN token_a_amount * a.price
          ELSE token_b_amount * b.price
        END
      ) AS usd_volume
    FROM
      dex."trades" t
      LEFT JOIN price a ON date_trunc('DAY', t.block_time) = a.datex
      AND token_a_address = a.contract_address
      LEFT JOIN price b ON date_trunc('DAY', t.block_time) = b.datex
      AND token_b_address = b.contract_address
    WHERE
      block_time > NOW() - '30 DAYS':: INTERVAL
      AND project = 'Uniswap'
    GROUP BY
      1,
      2
  )
SELECT
  rn,
  datex,
  pair,
  "Volume USD",
  "Protocol Revenue USD"
FROM (
  SELECT
    ROW_NUMBER() OVER (
      PARTITION BY datex
      ORDER BY
        usd_volume DESC NULLS LAST
    ) AS rn,
    datex,
    pair,
    usd_volume AS "Volume USD",
    usd_volume * 0.003 AS "Protocol Revenue USD"
  FROM
    volume
  WHERE
    usd_volume IS NOT NULL
) x
WHERE
  rn < 16
ORDER BY
  1 DESC;