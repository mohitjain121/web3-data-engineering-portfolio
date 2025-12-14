/* Description: Calculate Uniswap stkETH Pool TVL */
WITH 
weth_price AS (
  SELECT 
    date_trunc('DAY', minute) AS datex,
    AVG(price) AS weth_price
  FROM 
    prices."usd"
  WHERE 
    symbol = 'WETH' --WETH
    GROUP BY 1
  ),
  
ratio AS (
  SELECT 
    date_trunc('DAY', evt_block_time) AS datex,
    ABS(amount0/amount1) AS stketh_eth_ratio
  FROM 
    uniswap_v3."Pair_evt_Swap"
  WHERE 
    contract_address = '\x5D171a15D950c174d4Fd9Df9C8CC872A9972475E'
  ),
  
stketh_price AS (
  SELECT 
    r.datex,
    stketh_eth_ratio * weth_price AS stketh_price
  FROM 
    ratio r
    LEFT JOIN weth_price p ON r.datex = p.datex
  ),
  
tokens AS (
  SELECT 
    datex,
    SUM(stketh) OVER (
      ORDER BY 
        datex ASC
    ) AS stketh,
    SUM(weth) OVER (
      ORDER BY 
        datex ASC
    ) AS weth
  FROM (
    SELECT 
      datex,
      SUM(stketh) AS stketh,
      SUM(weth) AS weth
    FROM (
      SELECT 
        date_trunc('DAY', COALESCE(t1.evt_block_time, t2.evt_block_time)) AS datex,
        (-1) * t1.value / 10 ^ (18) AS stketh,
        (-1) * t2.value / 10 ^ (18) AS weth
      FROM 
        erc20."ERC20_evt_Transfer" t1
        FULL JOIN erc20."ERC20_evt_Transfer" t2 ON t1.evt_block_time = t2.evt_block_time
      WHERE 
        t1."from" = '\x5D171a15D950c174d4Fd9Df9C8CC872A9972475E'
        AND t1.contract_address = '\x2C5Bcad9Ade17428874855913Def0A02D8bE2324'
        AND t2."from" = '\x5D171a15D950c174d4Fd9Df9C8CC872A9972475E'
        AND t2.contract_address = '\xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2'
      
      UNION
      SELECT 
        date_trunc('DAY', COALESCE(t1.evt_block_time, t2.evt_block_time)) AS datex,
        t1.value / 10 ^ (18) AS stketh,
        t2.value / 10 ^ (18) AS weth
      FROM 
        erc20."ERC20_evt_Transfer" t1
        FULL JOIN erc20."ERC20_evt_Transfer" t2 ON t1.evt_block_time = t2.evt_block_time
      WHERE 
        t1."to" = '\x5D171a15D950c174d4Fd9Df9C8CC872A9972475E'
        AND t1.contract_address = '\x2C5Bcad9Ade17428874855913Def0A02D8bE2324'
        AND t2."to" = '\x5D171a15D950c174d4Fd9Df9C8CC872A9972475E'
        AND t2.contract_address = '\xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2'
    ) x
    GROUP BY 
      datex
  ) y
),

-- Calculate TVL
tvls AS (
  SELECT 
    t.datex,
    stketh_price,
    stketh,
    weth_price,
    weth,
    stketh * stketh_price + weth * weth_price AS "Uniswap stkETH Pool $TVL"
  FROM 
    tokens t
    INNER JOIN stketh_price p1 ON p1.datex = t.datex
    LEFT JOIN weth_price p2 ON p2.datex = t.datex
)

SELECT 
  datex,
  stketh_price,
  stketh,
  weth_price,
  weth,
  "Uniswap stkETH Pool $TVL"
FROM 
  tvls
ORDER BY 
  datex DESC;