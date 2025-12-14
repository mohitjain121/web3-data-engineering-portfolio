/* Description: Calculate token and USD TVL for Wombat abnbc Asset (LP-abnbc) */
WITH 
abnbc_price AS (
  SELECT 
    datex,
    abnbc_price
  FROM 
    dune_user_generated.abnbc_price
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
        contract_address = '\x9d2deaD9547EB65Aa78E239647a0c783f296406B' -- Wombat abnbc Asset (LP-abnbc)
        AND "to" != '\x0000000000000000000000000000000000000000'
      UNION ALL
      SELECT 
        date_trunc('DAY', "evt_block_time") AS datex,
        (-1) * value / 1e18 AS value
      FROM 
        bep20."BEP20_evt_Transfer"
      WHERE 
        contract_address = '\x9d2deaD9547EB65Aa78E239647a0c783f296406B' -- Wombat abnbc Asset (LP-abnbc)
        AND "from" != '\x0000000000000000000000000000000000000000'
    ) x
    GROUP BY 1
  ) y
)

SELECT 
  a.datex,
  abnbc_price,
  net_flow AS net_token_flow,
  net_flow * abnbc_price AS net_usd_flow,
  tvl AS token_tvl,
  tvl * abnbc_price AS usd_tvl
FROM 
  tvl a
  LEFT JOIN abnbc_price b ON a.datex = b.datex
WHERE 
  a.datex > '2022-09-12'
ORDER BY 
  1 DESC