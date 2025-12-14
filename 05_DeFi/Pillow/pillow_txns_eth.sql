/* Description: Calculate Ethereum deposits and withdrawals for a specific wallet. */

WITH
  deposit AS (
    SELECT
      -- Extract wallet address from 'from' field
      "from" AS wallet,
      -- Calculate total deposit in ETH, dividing by 1e18 to convert from wei
      SUM(value) / 1e18 AS eth_dep
    FROM
      ethereum."traces"
    WHERE
      -- Filter by wallet address and block time
      "to" = '\xe9BB903eB69972294686AEE93C1ed8749eC372Ad'
      AND block_time >= '2021-11-01'
    GROUP BY
      1
  ),
  withdraw AS (
    SELECT
      -- Extract wallet address from 'to' field
      "to" AS wallet,
      -- Calculate total withdrawal in ETH, dividing by 1e18 to convert from wei
      SUM(value) / 1e18 AS eth_with
    FROM
      ethereum."traces"
    WHERE
      -- Filter by wallet address and block time
      "from" = '\xe9BB903eB69972294686AEE93C1ed8749eC372Ad'
      AND block_time >= '2021-11-01'
    GROUP BY
      1
  )
SELECT
  -- Use COALESCE to handle NULL values in case of no match
  COALESCE(a.wallet, b.wallet) AS wallet,
  -- Select deposit amount
  eth_dep,
  -- Select withdrawal amount
  eth_with
FROM
  deposit a
  -- Perform full outer join to include all deposits and withdrawals
  FULL JOIN withdraw b ON a.wallet = b.wallet
-- Order results by deposit amount in descending order
ORDER BY
  2 DESC