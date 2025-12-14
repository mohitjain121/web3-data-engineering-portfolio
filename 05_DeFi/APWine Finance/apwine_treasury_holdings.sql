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
          FIRST_VALUE(price) OVER (
            PARTITION BY symbol
            ORDER BY
              minute DESC
          ) AS price
        FROM
          prices."usd"
        WHERE
          contract_address IN (
            SELECT
              contract_address
            FROM
              erc20."ERC20_evt_Transfer"
            WHERE
              "to" IN ('\xdbbfc051d200438dd5847b093b22484b842de9e7')
              OR "from" IN ('\xdbbfc051d200438dd5847b093b22484b842de9e7')
          )
          AND minute > NOW() - '7 DAYS':: INTERVAL
        GROUP BY
          1,
          2,
          3,
          price,
          minute
        UNION
        SELECT
          d.contract_address,
          decimals,
          symbol,
          FIRST_VALUE(median_price) OVER (
            PARTITION BY symbol
            ORDER BY
              hour DESC
          ) AS price
        FROM
          dex."view_token_prices" d
          JOIN erc20."tokens" e ON d.contract_address = e.contract_address
        WHERE
          d.contract_address IN (
            SELECT
              contract_address
            FROM
              erc20."ERC20_evt_Transfer"
            WHERE
              "to" IN ('\xdbbfc051d200438dd5847b093b22484b842de9e7')
              OR "from" IN ('\xdbbfc051d200438dd5847b093b22484b842de9e7')
          )
          AND hour > NOW() - '1 DAY':: INTERVAL
        GROUP BY
          1,
          2,
          3,
          median_price,
          hour
      ) x
    GROUP BY
      1,
      2,
      3
  ),
  holdings AS (
    SELECT
      token_address,
      FIRST_VALUE(amount_raw) OVER (
        PARTITION BY token_address
        ORDER BY
          "timestamp" DESC
      ) AS holding
    FROM
      erc20."token_balances_latest"
    WHERE
      "wallet_address" = '\xdbbfc051d200438dd5847b093b22484b842de9e7'
  )
SELECT
  DISTINCT CONCAT(
    '<a href="https://etherscan.io/address/0',
    SUBSTRING("token_address":: text, 2),
    '" target="_blank" >',
    "token_address",
    '</a>'
  ) AS token_address,
  symbol AS token,
  holding / 10 ^ decimals AS token_holdings,
  holding * price / 10 ^ decimals AS usd_holdings,
  (
    holding * price / 10 ^ decimals / SUM(holding * price / 10 ^ decimals) OVER ()
  ) AS percent_holding
FROM
  holdings h
  INNER JOIN price p ON h.token_address = p.contract_address
ORDER BY
  4 DESC