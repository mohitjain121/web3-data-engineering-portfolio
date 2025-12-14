/* Description: Calculate cumulative wallets by date. */

SELECT
  datex,
  wallets,
  SUM(wallets) OVER (
    ORDER BY
      datex ASC
  ) AS cumulative_wallets
FROM (
  SELECT
    datex,
    COUNT(DISTINCT wallet) AS wallets
  FROM (
    SELECT
      "sender" AS wallet,
      date_trunc('DAY', MIN(evt_block_time)) AS datex
    FROM
      wombat."DynamicPool_evt_Deposit"
    WHERE
      "token" = '\xc2E9d07F66A89c44062459A47a0D2Dc038E4fb16' -- stkBNB token
    GROUP BY
      1
  ) x
  GROUP BY
    1
) x
ORDER BY
  1 DESC;