/* Description: Calculate average and median holdings for a set of wallets. */

WITH
  price AS (
    SELECT
      contract_address,
      decimals,
      symbol,
      AVG(median_price) AS price
    FROM
      prices."approx_prices_from_dex_data"
    WHERE
      hour > NOW() - '1 days'::interval
    GROUP BY
      1,
      2,
      3
  ),
  holdings AS (
    SELECT
      wallet,
      contract_address,
      SUM(amount) AS amount
    FROM
      (
        SELECT
          "from" AS wallet,
          contract_address,
          (-1) * value AS amount
        FROM
          erc20."ERC20_evt_Transfer"
        WHERE
          "from" IN (
            '\xDf5fa32B726a5118281e74aD3B7C707423e28F8B',
            '\xeC5c16f3EAF86a801a3E89201DD39bDDD1786cBF',
            '\x9Ec01d2A66Ac9A6173050383e1EFD93f5b883294',
            '\x10DbC99C90234E4447f0366e8368d688f622475A',
            '\x64Af258F8522Bb9dD2c2B648B9CBBCDbe986B0BF',
            '\xb6bbE5a785F6cfEd3F65F2BA91AD20586B00f7E6',
            '\xcF10A8E7c907144cc87721aC1fD7Ac75a8aebeC7',
            '\x32ffC2374fA900FDe59D7B7388Bb4a9A9Dbe6123'
          )
        UNION
        SELECT
          "to" AS wallet,
          contract_address,
          value AS amount
        FROM
          erc20."ERC20_evt_Transfer"
        WHERE
          "to" IN (
            '\xDf5fa32B726a5118281e74aD3B7C707423e28F8B',
            '\xeC5c16f3EAF86a801a3E89201DD39bDDD1786cBF',
            '\x9Ec01d2A66Ac9A6173050383e1EFD93f5b883294',
            '\x10DbC99C90234E4447f0366e8368d688f622475A',
            '\x64Af258F8522Bb9dD2c2B648B9CBBCDbe986B0BF',
            '\xb6bbE5a785F6cfEd3F65F2BA91AD20586B00f7E6',
            '\xcF10A8E7c907144cc87721aC1fD7Ac75a8aebeC7',
            '\x32ffC2374fA900FDe59D7B7388Bb4a9A9Dbe6123'
          )
      ) x
    GROUP BY
      1,
      2
  )
SELECT
  AVG(usd_holdings) AS avg_holding,
  PERCENTILE_CONT(0.5) WITHIN GROUP(
    ORDER BY
      usd_holdings
  ) AS med_holding
FROM
  (
    SELECT
      wallet,
      SUM(usd_holdings) AS usd_holdings
    FROM
      (
        SELECT
          wallet,
          symbol,
          h.contract_address,
          amount * price / 10 ^ decimals AS usd_holdings
        FROM
          holdings h
          LEFT JOIN price p ON h.contract_address = p.contract_address
        WHERE
          amount > 0
      ) h
    GROUP BY
      1
  ) x