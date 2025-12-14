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
              "to" IN ('\xf5ba2e5dded276fc0f7a7637a61157a4be79c626')
              OR "from" IN ('\xf5ba2e5dded276fc0f7a7637a61157a4be79c626')
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
              "to" IN ('\xf5ba2e5dded276fc0f7a7637a61157a4be79c626')
              OR "from" IN ('\xf5ba2e5dded276fc0f7a7637a61157a4be79c626')
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
--   holdings AS (
--     SELECT
--       token_address,
--       FIRST_VALUE(amount_raw) OVER (
--         PARTITION BY token_address
--         ORDER BY
--           "timestamp" DESC
--       ) AS holding
--     FROM
--       erc20."token_balances_latest"
--     WHERE
--       "wallet_address" = '\xf5ba2e5dded276fc0f7a7637a61157a4be79c626'
--   )
holdings AS (
    SELECT
      token_address,
      SUM(holding) AS holding
    FROM
      (
        SELECT
          datex,
          token_address,
          SUM(amount) AS holding
        FROM
          (
            SELECT
              DATE_TRUNC('DAY', evt_block_time) AS datex,
              contract_address AS token_address,
              value AS amount
            FROM
              erc20."ERC20_evt_Transfer"
            WHERE
              "to" IN ('\xf5ba2e5dded276fc0f7a7637a61157a4be79c626')
            GROUP BY
              1,
              2,
              3
            UNION
            SELECT
              DATE_TRUNC('DAY', evt_block_time) AS datex,
              contract_address AS token_address,
              (-1) * value AS amount
            FROM
              erc20."ERC20_evt_Transfer"
            WHERE
              "from" IN ('\xf5ba2e5dded276fc0f7a7637a61157a4be79c626')
            GROUP BY
              1,
              2,
              3
          ) x
        GROUP BY
          1,
          2
      ) x
    GROUP BY
      1
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
  holding / 10 ^ COALESCE(decimals, 0) AS token_holdings,
  holding * price / 10 ^ decimals AS usd_holdings,
  (
    holding * price / 10 ^ decimals / SUM(holding * price / 10 ^ decimals) OVER ()
  ) AS percent_holding
FROM
  holdings h
  LEFT JOIN price p ON h.token_address = p.contract_address
ORDER BY
  4 ASC