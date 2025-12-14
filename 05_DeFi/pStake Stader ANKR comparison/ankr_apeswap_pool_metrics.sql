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
  ),
  
  -- Calculate daily WBNB and ABNBC token balances
  tokens AS (
    SELECT 
      datex,
      SUM(wbnb) OVER (ORDER BY datex ASC) AS wbnb,
      SUM(abnbc) OVER (ORDER BY datex ASC) AS abnbc
    FROM (
      SELECT 
        date_trunc('DAY', evt_block_time) AS datex,
        SUM(
          CASE 
            WHEN "to" = '\x1C3BFdA8d788689ab2Fb935a9499c67e098A9E84' 
            AND contract_address = '\xbb4cdb9cbd36b01bd1cbaebf2de08d9173bc095c'
            THEN value/1e18
            WHEN "from" = '\x1C3BFdA8d788689ab2Fb935a9499c67e098A9E84' 
            AND contract_address = '\xbb4cdb9cbd36b01bd1cbaebf2de08d9173bc095c'
            THEN (-1)*value/1e18
          END) AS wbnb,
        SUM(
          CASE 
            WHEN "to" = '\x1C3BFdA8d788689ab2Fb935a9499c67e098A9E84' 
            AND contract_address = '\xe85afccdafbe7f2b096f268e31cce3da8da2990a'
            THEN value/1e18
            WHEN "from" = '\x1C3BFdA8d788689ab2Fb935a9499c67e098A9E84' 
            AND contract_address = '\xe85afccdafbe7f2b096f268e31cce3da8da2990a'
            THEN (-1)*value/1e18
          END) AS abnbc
      FROM 
        bep20."BEP20_evt_Transfer"
      WHERE 
        evt_block_time > '2022-04-05'
    ) x
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