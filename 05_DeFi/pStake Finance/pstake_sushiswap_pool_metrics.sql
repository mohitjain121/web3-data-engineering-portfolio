/* Description: Calculate Sushiswap pool TVL and average prices */

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

token1 AS (
  SELECT 
    date_trunc('DAY', evt_block_time) AS datex,
    LAST_VALUE(reserve0/10^6) OVER (ORDER BY evt_block_time DESC) AS "stkXPRT",
    LAST_VALUE(reserve1/10^18) OVER (ORDER BY evt_block_time DESC) AS "WETH"
  FROM 
    sushi."Pair_evt_Sync"
  WHERE contract_address = '\xF9a0483b7ACe75319cb78C0f1c69A04d581F3D1A' --XPRT
),

token2 AS (
  SELECT 
    date_trunc('DAY', evt_block_time) AS datex,
    LAST_VALUE(reserve0/10^6) OVER (ORDER BY evt_block_time DESC) AS "stkAtom",
    LAST_VALUE(reserve1/10^18) OVER (ORDER BY evt_block_time DESC) AS "WETH"
  FROM 
    sushi."Pair_evt_Sync"
  WHERE contract_address = '\x195b2ed7dfb2bb19c63b8b06677d46934c0c4eea' --ATOM
),

pricetoken1 AS (
  SELECT 
    t1.datex,
    weth_price,
    t1."WETH" AS xprt_weth,
    "stkXPRT",
    weth_price*t1."WETH"/"stkXPRT" AS stkxprt_price
  FROM 
    token1 t1
    LEFT JOIN weth_price p ON t1.datex =  p.datex
),

pricetoken2 AS (
  SELECT 
    t2.datex,
    weth_price,
    t2."WETH" AS atom_weth,
    "stkAtom",
    weth_price*t2."WETH"/"stkAtom" AS stkatom_price
  FROM 
    token2 t2
    LEFT JOIN weth_price p ON t2.datex =  p.datex
),

tvl1 AS (
  SELECT 
    datex,
    stkxprt_price,
    "stkXPRT",
    "stkXPRT"*stkxprt_price + xprt_weth*weth_price AS "Sushiswap XPRT Pool $TVL"
  FROM pricetoken1
),

tvl2 AS (
  SELECT 
    datex,
    stkatom_price,
    "stkAtom",
    "stkAtom"*stkatom_price + atom_weth*weth_price AS "Sushiswap Atom Pool $TVL"
  FROM pricetoken2
),

tvl AS (
  SELECT 
    ROW_NUMBER() OVER (ORDER BY t2.datex ASC) as id,
    t2.datex,
    stkatom_price,
    "stkAtom",
    "Sushiswap Atom Pool $TVL",
    stkxprt_price,
    "stkXPRT",
    "Sushiswap XPRT Pool $TVL"
  FROM 
    tvl2 t2
    LEFT JOIN tvl1 t1 ON t2.datex = t1.datex
),

filled AS (
  SELECT 
    id,
    datex,
    stkatom_price,
    "stkAtom",
    "Sushiswap Atom Pool $TVL",
    stkxprt_price,
    "stkXPRT",
    "Sushiswap XPRT Pool $TVL",
    MAX(CASE WHEN datex IS NOT NULL THEN id END) OVER (ORDER BY id ROWS UNBOUNDED PRECEDING) AS gp1,
    MAX(CASE WHEN stkatom_price IS NOT NULL THEN id END) OVER (ORDER BY id ROWS UNBOUNDED PRECEDING) AS gp2,
    MAX(CASE WHEN "stkAtom" IS NOT NULL THEN id END) OVER (ORDER BY id ROWS UNBOUNDED PRECEDING) AS gp3,
    MAX(CASE WHEN "Sushiswap Atom Pool $TVL" IS NOT NULL THEN id END) OVER (ORDER BY id ROWS UNBOUNDED PRECEDING) AS gp4,
    MAX(CASE WHEN stkxprt_price IS NOT NULL THEN id END) OVER (ORDER BY id ROWS UNBOUNDED PRECEDING) AS gp5,
    MAX(CASE WHEN "stkXPRT" IS NOT NULL THEN id END) OVER (ORDER BY id ROWS UNBOUNDED PRECEDING) AS gp6,
    MAX(CASE WHEN "Sushiswap XPRT Pool $TVL" IS NOT NULL THEN id END) OVER (ORDER BY id ROWS UNBOUNDED PRECEDING) AS gp7
  FROM tvl
),

avg_tvl AS (
  SELECT 
    datex,
    AVG(stkatom_price) AS stkatom_price,
    AVG("stkAtom") AS "stkAtom",
    AVG("Sushiswap Atom Pool $TVL") AS "Sushiswap Atom Pool $TVL",
    AVG(stkxprt_price) AS stkxprt_price,
    AVG("stkXPRT") AS "stkXPRT",
    AVG("Sushiswap XPRT Pool $TVL") AS "Sushiswap XPRT Pool $TVL",
    AVG("Sushiswap Atom Pool $TVL" + "Sushiswap XPRT Pool $TVL") AS "Sushiswap Pool $TVL"
  FROM 
    (
      SELECT 
        id,
        (SELECT datex FROM tvl WHERE id = gp1) AS datex,
        (SELECT stkatom_price FROM tvl WHERE id = gp2) AS stkatom_price,
        (SELECT "stkAtom" FROM tvl WHERE id = gp3) AS "stkAtom",
        (SELECT "Sushiswap Atom Pool $TVL" FROM tvl WHERE id = gp4) AS "Sushiswap Atom Pool $TVL",
        (SELECT stkxprt_price FROM tvl WHERE id = gp5) AS stkxprt_price,
        (SELECT "stkXPRT" FROM tvl WHERE id = gp6) AS "stkXPRT",
        (SELECT "Sushiswap XPRT Pool $TVL" FROM tvl WHERE id = gp7) AS "Sushiswap XPRT Pool $TVL"
      FROM filled
    ) v
  GROUP BY 1
  ORDER BY 1 DESC
)

SELECT * FROM avg_tvl;