/* Description: Calculate cumulative volume of WBNB and stkBNB tokens */
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
  
  -- Get daily WBNB and stkBNB reserves
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
  
  -- Calculate stkBNB price
  price AS (
    SELECT 
      t.datex,
      wbnb_price,
      wbnb_price * wbnb / stkbnb AS stkbnb_price
    FROM
      tokens t
      LEFT JOIN wbnb_price p ON t.datex =  p.datex
  ),
  
  -- Get daily stkBNB and WBNB volumes
  token AS (
    SELECT 
      date_trunc('DAY', evt_block_time) AS datex,
      SUM(CASE WHEN contract_address = '\xc2E9d07F66A89c44062459A47a0D2Dc038E4fb16' THEN value/1e18 END) AS stkbnb,
      SUM(CASE WHEN contract_address = '\xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c' THEN value/1e18 END) AS wbnb
    FROM
      bep20."BEP20_evt_Transfer"
    WHERE
      "from" = '\x6a75ac4b8d8e76d15502e69be4cb6325422833b4'
      AND "to" = '\xaa2527ff1893e0d40d4a454623d362b79e8bb7f1'
    GROUP BY 1
  )

SELECT 
  datex,
  volume,
  SUM(volume) OVER (ORDER BY datex ASC) AS cumulative_volume
FROM (
  SELECT 
    DISTINCT 
    a.datex,
    stkbnb * stkbnb_price + wbnb * wbnb_price AS volume
  FROM 
    token a
    LEFT JOIN price p ON p.datex = a.datex
) x
ORDER BY 1 DESC;