/* Description: Calculate total holdings for each token symbol */

WITH
  price AS (
    SELECT
      contract_address,
      decimals,
      symbol,
      AVG(price) AS price
    FROM
      (
        SELECT
          contract_address,
          decimals,
          symbol,
          AVG(price) AS price
        FROM
          prices."usd"
        WHERE
          minute > NOW() - '1 DAYS':: INTERVAL
        GROUP BY
          1,
          2,
          3
        UNION
        SELECT
          contract_address,
          decimals,
          p.symbol,
          AVG(price) AS price
        FROM
          prices."layer1_usd" p
          LEFT JOIN erc20."tokens" t ON t.symbol = p.symbol
        WHERE
          minute > NOW() - '1 DAYS':: INTERVAL
        GROUP BY
          1,
          2,
          3
        UNION
        SELECT
          p.contract_address,
          decimals,
          p.symbol,
          AVG(median_price) AS price
        FROM
          dex."dex_token_prices" p
          LEFT JOIN erc20."tokens" t ON t.contract_address = p.contract_address
        WHERE
          hour > NOW() - '1 DAYS':: INTERVAL
        GROUP BY
          1,
          2,
          3
        UNION
        SELECT
          p.contract_address,
          decimals,
          t.symbol,
          AVG(median_price) AS price
        FROM
          dex."view_token_prices" p
          INNER JOIN erc20."tokens" t ON t.contract_address = p.contract_address
        WHERE
          hour > NOW() - '1 DAYS':: INTERVAL
        GROUP BY
          1,
          2,
          3
      ) p
    WHERE
      contract_address IS NOT NULL
      AND decimals IS NOT NULL
      AND symbol IS NOT NULL
      AND price IS NOT NULL
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
            '\x1Cf693eceEbEee99aD60e82973E2d4829C801335',
            '\x71c199C366625329064df3d08191CDC0e85AC2eA',
            '\xd61daEBC28274d1feaAf51F11179cd264e4105fB',
            '\xb7c60C8F27f6A944F923684606Fe3B5CE8998a2e',
            '\x60ecadC9fa4D4938f554954ec6DA578EBe191481',
            '\xC00fC2775cce5b61ffd6Ec1eEc0De0119f25DC87',
            '\x3bB3951A9F142d4d8ae3F83086E478152C8872d8',
            '\x24380d5a7c4239F2000fB4a6e07804a09597802e',
            '\x1d11e78148849200f3e937f31e8A9F66433E69f8'
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
            '\x1Cf693eceEbEee99aD60e82973E2d4829C801335',
            '\x71c199C366625329064df3d08191CDC0e85AC2eA',
            '\xd61daEBC28274d1feaAf51F11179cd264e4105fB',
            '\xb7c60C8F27f6A944F923684606Fe3B5CE8998a2e',
            '\x60ecadC9fa4D4938f554954ec6DA578EBe191481',
            '\xC00fC2775cce5b61ffd6Ec1eEc0De0119f25DC87',
            '\x3bB3951A9F142d4d8ae3F83086E478152C8872d8',
            '\x24380d5a7c4239F2000fB4a6e07804a09597802e',
            '\x1d11e78148849200f3e937f31e8A9F66433E69f8'
          )
      ) x
    GROUP BY
      1,
      2
  )
SELECT
  symbol,
  h.contract_address,
  COUNT(wallet) AS count_wallets,
  --   amount,
  SUM(usd_holdings) AS total_sum_held
FROM
  (
    SELECT
      CONCAT('<a href="https://etherscan.io/address/0', SUBSTRING("wallet"::text, 2), '" target="_blank" >', "wallet", '</a>') AS wallet,
      symbol,
      CONCAT('<a href="https://etherscan.io/address/0', SUBSTRING(h.contract_address::text, 2), '" target="_blank" >', h.contract_address, '</a>') AS contract_address,
      --   amount/10^decimals AS amount,
      amount * price / 10 ^ decimals AS usd_holdings
    FROM
      holdings h
      LEFT JOIN price p ON h.contract_address = p.contract_address
    WHERE
      amount > 0
      AND amount IS NOT NULL
  ) h
WHERE
  -- amount IS NOT NULL
  usd_holdings IS NOT NULL
GROUP BY
  1,
  2
ORDER BY
  4 DESC