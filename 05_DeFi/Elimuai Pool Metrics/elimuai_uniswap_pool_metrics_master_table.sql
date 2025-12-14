/* Description: Calculate Uniswap pool TVL for elimu.ai-WETH pair */

WITH
  weth_price AS (
    SELECT
      date_trunc('DAY', minute) AS datex,
      AVG(price) AS weth_price
    FROM
      prices."usd"
    WHERE
      symbol = 'WETH' --WETH
    GROUP BY
      1
  ),
  ratio AS (
    SELECT
      datex,
      AVG(elimu_eth_ratio) AS elimu_eth_ratio
    FROM
      (
        SELECT
          date_trunc('DAY', evt_block_time) AS datex,
          ABS("amount0Out" / "amount1In") AS elimu_eth_ratio
        FROM
          uniswap_v2."Pair_evt_Swap"
        WHERE
          contract_address = '\xa0d230Dca71a813C68c278eF45a7DaC0E584EE61'
          AND "amount1In" != 0
        UNION
        SELECT
          date_trunc('DAY', evt_block_time) AS datex,
          ABS("amount0In" / "amount1Out") AS elimu_eth_ratio
        FROM
          uniswap_v2."Pair_evt_Swap"
        WHERE
          contract_address = '\xa0d230Dca71a813C68c278eF45a7DaC0E584EE61'
          AND "amount1Out" != 0
      ) x
    GROUP BY
      1
  ),
  elimu_price AS (
    SELECT
      r.datex,
      AVG(elimu_eth_ratio * weth_price) AS elimu_price
    FROM
      ratio r
      LEFT JOIN weth_price p ON r.datex = p.datex
    GROUP BY
      1
  ),
  tokens AS (
    SELECT
      datex,
      LAST_VALUE(reserve0 / 10 ^ 18) OVER (
        PARTITION BY datex
        ORDER BY
          datex DESC
      ) AS weth,
      LAST_VALUE(reserve1 / 10 ^ 18) OVER (
        PARTITION BY datex
        ORDER BY
          datex DESC
      ) AS elimu
    FROM
      (
        SELECT
          date_trunc('DAY', evt_block_time) AS datex,
          reserve0,
          reserve1
        FROM
          uniswap_v2."Pair_evt_Sync"
        WHERE
          contract_address = '\xa0d230Dca71a813C68c278eF45a7DaC0E584EE61'
          AND evt_block_time > '2021-12-12'
      ) x
  )
SELECT
  t.datex,
  p1.elimu_price,
  t.elimu,
  t.elimu * p1.elimu_price AS elimu_liquidity,
  p2.weth_price,
  t.weth,
  t.weth * p2.weth_price AS weth_liquidity,
  t.elimu * p1.elimu_price + t.weth * p2.weth_price AS "Uniswap elimu.ai-WETH Pool $TVL"
FROM
  tokens t
  INNER JOIN elimu_price p1 ON p1.datex = t.datex
  LEFT JOIN weth_price p2 ON p2.datex = t.datex
ORDER BY
  1 DESC;