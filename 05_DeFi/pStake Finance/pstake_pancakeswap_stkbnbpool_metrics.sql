/* Description: Calculate WBNB and stkBNB prices and pool TVL */
WITH 
  -- Calculate daily WBNB price
  wbnb_price AS (
    SELECT 
      date_trunc('DAY', minute) AS datex,
      AVG(price) AS wbnb_price
    FROM 
      prices."usd"
    WHERE 
      symbol = 'WBNB' -- wbnb
    GROUP BY 1
  ),
  
  -- Extract WBNB and stkBNB reserves from PancakePair_evt_Sync
  tokens AS (
    SELECT 
      date_trunc('DAY', evt_block_time) AS datex,
      FIRST_VALUE(reserve0/1e18) OVER (PARTITION BY date_trunc('DAY', evt_block_time) ORDER BY evt_block_time DESC) AS wbnb,
      FIRST_VALUE(reserve1/1e18) OVER (PARTITION BY date_trunc('DAY', evt_block_time) ORDER BY evt_block_time DESC) AS stkbnb
    FROM 
      pancakeswap_v2."PancakePair_evt_Sync"
    WHERE
      contract_address = '\xaa2527ff1893e0d40d4a454623d362b79e8bb7f1'
    ORDER BY 1 ASC
  ),
  
  -- Calculate stkBNB price using WBNB price and reserves
  price AS (
    SELECT 
      t.datex,
      wbnb_price,
      wbnb_price * wbnb / stkbnb AS stkbnb_price
    FROM
      tokens t
      LEFT JOIN wbnb_price p ON t.datex =  p.datex
  )

SELECT 
  t.datex, 
  AVG(stkbnb_price) AS stkbnb_price, 
  AVG(wbnb_price) AS wbnb_price, 
  AVG(stkbnb) AS stkbnb, 
  AVG(wbnb) AS wbnb, 
  AVG(stkbnb * stkbnb_price + wbnb * wbnb_price) AS stkbnb_pool_tvl
FROM 
  tokens t
  LEFT JOIN price p ON p.datex = t.datex
GROUP BY 1
ORDER BY 1 DESC;