/* Description: Calculate Wombat bnbx asset (LP-bnbx) TVL and net token flow */
WITH 
bnbx_price AS (
  SELECT 
    datex,
    bnbx_price
  FROM 
    dune_user_generated.bnbx_price
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
        contract_address = '\x10F7C62f47F19e3cE08fef38f74E3C0bB31FC24f'  -- Wombat bnbx Asset (LP-bnbx)
        AND "to" != '\x0000000000000000000000000000000000000000'
      UNION ALL
      SELECT 
        date_trunc('DAY', "evt_block_time") AS datex,
        (-1) * value / 1e18 AS value
      FROM 
        bep20."BEP20_evt_Transfer"
      WHERE 
        contract_address = '\x10F7C62f47F19e3cE08fef38f74E3C0bB31FC24f'  -- Wombat bnbx Asset (LP-bnbx)
        AND "from" != '\x0000000000000000000000000000000000000000'
    ) x
    GROUP BY 1
  )
)

SELECT 
  a.datex,
  bnbx_price,
  net_flow AS net_token_flow,
  net_flow * bnbx_price AS net_usd_flow,
  tvl AS token_tvl,
  tvl * bnbx_price AS usd_tvl
FROM 
  tvl a
  LEFT JOIN bnbx_price b ON a.datex = b.datex
WHERE 
  a.datex > '2022-09-12'
ORDER BY 
  1 DESC