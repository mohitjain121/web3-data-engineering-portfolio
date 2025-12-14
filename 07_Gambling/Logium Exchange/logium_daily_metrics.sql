/* Description: Calculate daily and total metrics for a specific contract address. */

WITH
  price AS (
    SELECT
      hour:: DATE AS datex,
      decimals,
      contract_address,
      AVG(median_price) AS price
    FROM
      prices."prices_from_dex_data"
    WHERE
      symbol = 'USDC'
    GROUP BY
      1,
      2,
      3
  )
SELECT
  datex,
  users_daily,
  SUM(COALESCE(users_daily, 0)) OVER (
    ORDER BY
      datex
  ) AS users_total,
  count_deposits_daily,
  SUM(COALESCE(count_deposits_daily, 0)) OVER (
    ORDER BY
      datex
  ) AS count_deposits_total,
  sum_deposits_daily,
  SUM(COALESCE(sum_deposits_daily, 0)) OVER (
    ORDER BY
      datex
  ) AS sum_deposits_total,
  SUM(COALESCE(tvl_collateral, 0)) OVER (
    ORDER BY
      datex
  ) AS tvl_collateral,
  count_bets_daily,
  SUM(COALESCE(count_bets_daily, 0)) OVER (
    ORDER BY
      datex
  ) AS count_bets_total,
  volume_bets_daily,
  SUM(COALESCE(volume_bets_daily, 0)) OVER (
    ORDER BY
      datex
  ) AS volume_bets_total,
  fees_daily,
  SUM(COALESCE(fees_daily, 0)) OVER (
    ORDER BY
      datex
  ) AS fees_total
FROM
  (
    SELECT
      DISTINCT date_trunc('DAY', block_time) AS datex,
      COUNT(
        DISTINCT CASE
          WHEN SUBSTRING(x.data for 4) = '\x54469aea' THEN x."from"
        END
      ) AS users_daily,
      COUNT(
        DISTINCT CASE
          WHEN SUBSTRING(x.data for 4) = '\x54469aea' THEN hash
        END
      ) AS count_deposits_daily,
      COALESCE(
        SUM(
          DISTINCT CASE
            WHEN SUBSTRING(x.data for 4) = '\x54469aea' THEN t.value * price / 10 ^ decimals
          END
        ),
        0
      ) AS sum_deposits_daily,
      SUM(
        DISTINCT CASE
          WHEN SUBSTRING(x.data for 4) = '\x02387a7b' THEN (-1) * t.value * price / 10 ^ decimals
          WHEN SUBSTRING(x.data for 4) = '\x54469aea' THEN t.value * price / 10 ^ decimals
        END
      ) AS tvl_collateral,
      COUNT(
        DISTINCT CASE
          WHEN SUBSTRING(x.data for 4) = '\xb9104f82' THEN hash
        END
      ) AS count_bets_daily,
      COALESCE(
        SUM(
          DISTINCT CASE
            WHEN SUBSTRING(x.data for 4) = '\xb9104f82' THEN t.value * price / 10 ^ decimals
          END
        ),
        0
      ) AS volume_bets_daily,
      COALESCE(
        SUM(
          DISTINCT CASE
            WHEN SUBSTRING(x.data for 4) = '\xb9104f82' THEN t.value * price * 0.05 / 10 ^ decimals
          END
        ),
        0
      ) AS fees_daily
    FROM
      ethereum."transactions" x
      INNER JOIN erc20."ERC20_evt_Transfer" t ON t.evt_tx_hash = x.hash
      LEFT JOIN price p ON p.datex = x.block_time:: DATE
      AND p.contract_address = t.contract_address
    WHERE
      x."to" = '\xc61d1dcCEeec03c94d729D8F8344ce3Be75d09fE'
      AND success = true
    GROUP BY
      1
  ) x
ORDER BY
  1 DESC;