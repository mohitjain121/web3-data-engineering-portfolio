/* Description: Calculate the total USD holdings for each symbol across wallets. */

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
      hour > NOW() - '7 DAYS':: INTERVAL
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
            '\xcf0Fb4D249b8C2F17dd805aC2b6F28fFC3D0049C',
            '\x71c199C366625329064df3d08191CDC0e85AC2eA',
            '\xEd55793bda1aeC0A3a98cc5f092e071E5785106C',
            '\xaD928e545cf5598802B3c601E04B0CFE6bf6351C',
            '\x304160997E2D06fbfc0f54a8a714DC4cDf7B9E5F',
            '\xF68D2BfCecd7895BBa05a7451Dd09A1749026454',
            '\xA297A06221aB3c846354e7Fb1B37EB5DA06bDA21',
            '\xaB888291F4127352B655fd476F64AC2ebfb8fe76',
            '\x5B36002E5Ee1103A44246f67b067FD5509b97A9E'
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
            '\xcf0Fb4D249b8C2F17dd805aC2b6F28fFC3D0049C',
            '\x71c199C366625329064df3d08191CDC0e85AC2eA',
            '\xEd55793bda1aeC0A3a98cc5f092e071E5785106C',
            '\xaD928e545cf5598802B3c601E04B0CFE6bf6351C',
            '\x304160997E2D06fbfc0f54a8a714DC4cDf7B9E5F',
            '\xF68D2BfCecd7895BBa05a7451Dd09A1749026454',
            '\xA297A06221aB3c846354e7Fb1B37EB5DA06bDA21',
            '\xaB888291F4127352B655fd476F64AC2ebfb8fe76',
            '\x5B36002E5Ee1103A44246f67b067FD5509b97A9E',
            '\x52B0c756d6f36af804C51211BD5A1fA4AB5dc911'
          )
      ) x
    GROUP BY
      1,
      2
  )
SELECT
  symbol,
  contract_address,
  COUNT(wallet) AS count_wallets,
  SUM(usd_holdings) AS sum_held
FROM
  (
    SELECT
      wallet,
      symbol,
      h.contract_address,
      amount * price / POWER(10, decimals) AS usd_holdings
    FROM
      holdings h
      LEFT JOIN price p ON h.contract_address = p.contract_address
    WHERE
      amount > 0
  ) h
WHERE
  usd_holdings IS NOT NULL
GROUP BY
  1,
  2
ORDER BY
  4 DESC