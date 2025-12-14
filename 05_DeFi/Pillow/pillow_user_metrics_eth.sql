/* Description: Calculate Ethereum deposits and withdrawals for a specific wallet. */

WITH
  deposit AS (
    SELECT
      "from" AS wallet,
      SUM(value) / 1e18 AS eth_dep
    FROM
      ethereum."traces"
    WHERE
      "to" = '\xe9BB903eB69972294686AEE93C1ed8749eC372Ad'
      AND block_time >= '2021-11-01'
    GROUP BY
      1
  ),
  withdraw AS (
    SELECT
      "to" AS wallet,
      SUM(value) / 1e18 AS eth_with
    FROM
      ethereum."traces"
    WHERE
      "from" = '\xe9BB903eB69972294686AEE93C1ed8749eC372Ad'
      AND block_time >= '2021-11-01'
      AND "to" NOT IN (
        '\x7419348db6aa67773bd5bee119e3b894dfbf34e4',
        '\x7a7e5d6963bfc8d6055be42e6b114f34c03f7d45',
        '\xfc70d765f3570b5800972c27040b7f50f7497bf8',
        '\x4f8d7711d18344f86a5f27863051964d333798e2'
      )
    GROUP BY
      1
  )
SELECT
  SUM(eth_dep) AS eth_dep,
  COUNT(DISTINCT CASE WHEN eth_dep > 0 THEN wallet END) AS eth_depositors,
  SUM(eth_with) AS eth_with,
  COUNT(DISTINCT CASE WHEN eth_with > 0 THEN wallet END) AS eth_withdrawers
FROM (
  SELECT
    COALESCE(a.wallet, b.wallet) AS wallet,
    eth_dep,
    eth_with
  FROM
    deposit a
    FULL JOIN withdraw b ON a.wallet = b.wallet
) x