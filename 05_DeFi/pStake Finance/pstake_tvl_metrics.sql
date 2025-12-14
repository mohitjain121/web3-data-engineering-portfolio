/* Description: Calculate TVL for ATOM, XPRT, and ETH */
WITH 
  -- Calculate daily price for ATOM
  price1 AS (
    SELECT 
      date_trunc('DAY', minute) AS datex,
      AVG(price) AS price
    FROM 
      prices."layer1_usd"
    WHERE 
      symbol = 'ATOM'
    GROUP BY 
      1
  ), 

  -- Calculate daily price for XPRT
  price2 AS (
    SELECT 
      date_trunc('DAY', hour) AS datex,
      AVG(median_price) AS price
    FROM 
      dex."view_token_prices"
    WHERE 
      contract_address = '\x45e007750Cc74B1D2b4DD7072230278d9602C499'
    GROUP BY 
      1
  ), 

  -- Calculate daily price for ETH
  price3 AS (
    SELECT 
      date_trunc('DAY', hour) AS datex,
      AVG(median_price) AS price
    FROM 
      dex."view_token_prices"
    WHERE 
      contract_address = '\xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2'
    GROUP BY 
      1
  ), 

  -- Calculate daily TVL for ATOM
  token1 AS (
    SELECT 
      datex,
      SUM("Net Asset Change Weekly") OVER (ORDER BY datex ASC) AS "Vault Total Value Locked"
    FROM (
      SELECT 
        date_trunc('DAY', evt_block_time) AS datex,
        SUM(CASE 
            WHEN "from" = '\x0000000000000000000000000000000000000000' THEN value/10^6 
            WHEN "to" = '\x0000000000000000000000000000000000000000' THEN -value/10^6 
            ELSE NULL END) AS "Net Asset Change Weekly"
      FROM 
        erc20."ERC20_evt_Transfer"
      WHERE 
        contract_address = '\x44017598f2AF1bD733F9D87b5017b4E7c1B28DDE' --ATOM
      GROUP BY 
      1
    ) a
  ), 

  -- Calculate daily TVL for XPRT
  token2 AS (
    SELECT 
      datex,
      SUM("Net Asset Change Weekly") OVER (ORDER BY datex ASC) AS "Vault Total Value Locked"
    FROM (
      SELECT 
        date_trunc('DAY', evt_block_time) AS datex,
        SUM(CASE 
            WHEN "from" = '\x0000000000000000000000000000000000000000' THEN value/10^6 
            WHEN "to" = '\x0000000000000000000000000000000000000000' THEN -value/10^6 
            ELSE NULL END) AS "Net Asset Change Weekly"
      FROM 
        erc20."ERC20_evt_Transfer"
      WHERE 
        contract_address = '\x45e007750Cc74B1D2b4DD7072230278d9602C499' --XPRT
      GROUP BY 
      1
    ) a
  ), 

  -- Calculate daily TVL for ETH
  token3 AS (
    SELECT 
      date_trunc('DAY', evt_block_time) AS datex,
      SUM(CASE 
            WHEN "from" = '\x0000000000000000000000000000000000000000' THEN value/10^18 
            WHEN "to" = '\x0000000000000000000000000000000000000000' THEN -value/10^18 
            ELSE NULL END) AS net_asset_change
    FROM 
      erc20."ERC20_evt_Transfer"
    WHERE 
      contract_address = '\x2C5Bcad9Ade17428874855913Def0A02D8bE2324' --ETH
    GROUP BY 
    1
  ),

  -- Generate dummy data for ETH
  generateDummyData_3 AS (
    SELECT 
      "generated_date",
      0 AS net_asset_change
    FROM 
      token3
      CROSS JOIN generate_series('2021-10-20', NOW(), '1 day') AS "generated_date"
  ),

  -- Calculate daily TVL for ETH with dummy data
  token_3_tvl AS (
    SELECT 
      datex,
      SUM(net_asset_change) OVER (ORDER BY datex) AS "Vault Total Value Locked"
    FROM (
      SELECT 
        *
      FROM 
        token3
      UNION ALL
      SELECT 
        *
      FROM 
        generateDummyData_3
    ) x
  )

SELECT 
  t1.datex,
  p1.price AS "Atom Price",
  t1."Vault Total Value Locked" AS "Atoms Staked",
  p1.price * t1."Vault Total Value Locked" AS "Atom $TVL",
  p2.price AS "XPRT Price",
  t2."Vault Total Value Locked" AS "XPRTs Staked",
  p2.price * t2."Vault Total Value Locked" AS "XPRT $TVL",
  p3.price AS "ETH Price",
  t3."Vault Total Value Locked" AS "ETH Staked",
  p3.price * t3."Vault Total Value Locked" AS "ETH $TVL",
  t1."Vault Total Value Locked" * p1.price + COALESCE(t2."Vault Total Value Locked" * p2.price, 0) + COALESCE(t3."Vault Total Value Locked" * p3.price, 0) AS "pStake $TVL"
FROM 
  token1 t1
  LEFT JOIN token2 t2 ON t2.datex = t1.datex
  LEFT JOIN token_3_tvl t3 ON t3.datex = t1.datex
  LEFT JOIN price1 p1 ON p1.datex = t1.datex
  LEFT JOIN price2 p2 ON p2.datex = t1.datex
  LEFT JOIN price3 p3 ON p3.datex = t1.datex
WHERE 
  p1.price IS NOT NULL AND p2.price IS NOT NULL AND p3.price IS NOT NULL
ORDER BY 
  1 DESC