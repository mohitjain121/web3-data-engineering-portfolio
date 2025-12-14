/* Description: Calculate Sushiswap XPRT Pool $TVL */
WITH 
  weth_price AS (
    SELECT 
      date_trunc('DAY', minute) AS datex,
      AVG(price) AS weth_price
    FROM 
      prices."usd"
    WHERE 
      symbol = 'WETH' 
    GROUP BY 1
  ),
  
  tokens AS (
    SELECT 
      date_trunc('DAY', evt_block_time) AS datex,
      LAST_VALUE(reserve0/10^6) OVER (ORDER BY evt_block_time DESC) AS "stKXPRT",
      LAST_VALUE(reserve1/10^18) OVER (ORDER BY evt_block_time DESC) AS "WETH"
    FROM 
      sushi."Pair_evt_Sync"
    WHERE 
      contract_address = '\xF9a0483b7ACe75319cb78C0f1c69A04d581F3D1A'
    ORDER BY 1 ASC
  ),
  
  price AS (
    SELECT 
      t.datex,
      weth_price,
      weth_price*"WETH"/"stKXPRT" AS stkxprt_price
    FROM 
      tokens t
      LEFT JOIN weth_price p ON t.datex =  p.datex
  )

SELECT 
  t.datex, 
  AVG(stkxprt_price) AS stkxprt_price, 
  AVG(weth_price) AS weth_price, 
  AVG("stKXPRT") AS stKXPRT, 
  AVG("WETH") AS WETH, 
  AVG("stKXPRT"*stkxprt_price + "WETH"*weth_price) AS "Sushiswap XPRT Pool $TVL"
FROM 
  tokens t
  LEFT JOIN price p ON p.datex = t.datex
GROUP BY 1
ORDER BY 1 DESC;