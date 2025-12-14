/* Description: Calculate cumulative wallet count by date. */

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
      "token" = '\xe85afccdafbe7f2b096f268e31cce3da8da2990a' -- aBNBc token
    GROUP BY
      1
  ) x
  GROUP BY
    1
) x
ORDER BY
  1 DESC;