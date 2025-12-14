/* Description: Calculate average prices and pool TVL for WBNB and ABNBC tokens. */

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
  
  -- Extract daily WBNB and ABNBC reserves
  tokens AS (
    SELECT 
      date_trunc('DAY', evt_block_time) AS datex,
      FIRST_VALUE(reserve0/1e18) OVER (PARTITION BY date_trunc('DAY', evt_block_time) ORDER BY evt_block_time DESC) AS wbnb,
      FIRST_VALUE(reserve1/1e18) OVER (PARTITION BY date_trunc('DAY', evt_block_time) ORDER BY evt_block_time DESC) AS abnbc
    FROM 
      pancakeswap_v2."PancakePair_evt_Sync"
    WHERE
      contract_address = '\x272c2CF847A49215A3A1D4bFf8760E503A06f880'
    ORDER BY 1 ASC
  ),
  
  -- Calculate daily ABNBC price
  price AS (
    SELECT 
      t.datex,
      wbnb_price,
      wbnb_price * wbnb / abnbc AS abnbc_price
    FROM
      tokens t
      LEFT JOIN wbnb_price p ON t.datex = p.datex
  )

SELECT 
  t.datex, 
  AVG(abnbc_price) AS abnbc_price, 
  AVG(wbnb_price) AS wbnb_price, 
  AVG(abnbc) AS abnbc, 
  AVG(wbnb) AS wbnb, 
  AVG(abnbc * abnbc_price + wbnb * wbnb_price) AS abnbc_pool_tvl
FROM 
  tokens t
  LEFT JOIN price p ON p.datex = t.datex
GROUP BY 1
ORDER BY 1 DESC;