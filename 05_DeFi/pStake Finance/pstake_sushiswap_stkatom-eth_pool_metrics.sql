/* Description: Calculate Sushiswap Atom Pool TVL and average prices */
WITH 
  -- Calculate daily WETH price
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
  
  -- Get last value of reserve0 and reserve1 for each day
  tokens AS (
    SELECT 
      date_trunc('DAY', evt_block_time) AS datex,
      LAST_VALUE(reserve0/10^6) OVER (ORDER BY evt_block_time DESC) AS "stKAtom",
      LAST_VALUE(reserve1/10^18) OVER (ORDER BY evt_block_time DESC) AS "WETH"
    FROM 
      sushi."Pair_evt_Sync"
    WHERE 
      contract_address = '\x195b2ed7dfb2bb19c63b8b06677d46934c0c4eea'
    ORDER BY 1 ASC
  ),
  
  -- Calculate stkatom_price by joining weth_price and tokens
  price AS (
    SELECT 
      t.datex,
      weth_price,
      weth_price*"WETH"/"stKAtom" AS stkatom_price
    FROM 
      tokens t
      LEFT JOIN weth_price p ON t.datex =  p.datex
  )

SELECT 
  t.datex, 
  AVG(stkatom_price) AS stkatom_price, 
  AVG(weth_price) AS weth_price, 
  AVG("stKAtom") AS stKAtom, 
  AVG("WETH") AS WETH, 
  AVG("stKAtom"*stkatom_price + "WETH"*weth_price) AS "Sushiswap Atom Pool $TVL"
FROM 
  tokens t
  LEFT JOIN price p ON p.datex = t.datex
GROUP BY 1
ORDER BY 1 DESC;