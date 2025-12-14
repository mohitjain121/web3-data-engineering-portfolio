/* Description: Calculate Wombat stkBNB asset (LP-stkBNB) TVL and token flow */
WITH 
stkbnb_price AS (
  SELECT 
    datex,
    stkbnb_price
  FROM 
    dune_user_generated.stkbnb_price
),

tvl AS (
  SELECT 
    datex,
    net_flow,
    SUM(net_flow) OVER (ORDER BY datex ASC) AS tvl
  FROM (
    SELECT 
      datex,
      SUM(value) AS net_flow
    FROM (
      SELECT 
        date_trunc('DAY', "evt_block_time") AS datex,
        value / 1e18 AS value
      FROM 
        bep20."BEP20_evt_Transfer"
      WHERE 
        contract_address = '\xc496f42eA6Fc72aF434F48469b847A469fe0D17f'  -- Wombat stkBNB Asset (LP-stkBNB)
        AND "to" != '\x0000000000000000000000000000000000000000'
      UNION ALL
      SELECT 
        date_trunc('DAY', "evt_block_time") AS datex,
        (-1) * value / 1e18 AS value
      FROM 
        bep20."BEP20_evt_Transfer"
      WHERE 
        contract_address = '\xc496f42eA6Fc72aF434F48469b847A469fe0D17f'  -- Wombat stkBNB Asset (LP-stkBNB)
        AND "from" != '\x0000000000000000000000000000000000000000'
    ) x
    GROUP BY 1
  )
)

SELECT 
  a.datex,
  stkbnb_price,
  net_flow AS net_token_flow,
  net_flow * stkbnb_price AS net_usd_flow,
  tvl AS token_tvl,
  tvl * stkbnb_price AS usd_tvl
FROM 
  tvl a
  LEFT JOIN stkbnb_price b ON a.datex = b.datex
ORDER BY 
  1 DESC