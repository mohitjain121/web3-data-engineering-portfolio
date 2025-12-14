/* Description: Calculate token TVL and vault TVL by multiplying token TVL with stkbnb price */
WITH price AS (
  SELECT 
    datex,
    stkbnb_price
  FROM 
    dune_user_generated.stkbnb_price
),

tokens AS (
  SELECT 
    datex,
    SUM(asset_change) OVER (ORDER BY datex ASC) AS vault_tvl
  FROM (
    SELECT 
      date_trunc('DAY', evt_block_time) AS datex,
      SUM(
        CASE 
          WHEN "from" = '\x0000000000000000000000000000000000000000' THEN value/1e18 
          WHEN "to" = '\x0000000000000000000000000000000000000000' THEN (-1)*value/1e18
        END) AS asset_change
    FROM 
      erc20_bnb.evt_Transfer
    WHERE "contract_address" = '\xc2E9d07F66A89c44062459A47a0D2Dc038E4fb16'
    GROUP BY 1
  ) a
)

SELECT 
  t.datex,
  vault_tvl AS token_tvl,
  vault_tvl * stkbnb_price AS vault_tvl_value
FROM 
  tokens t
  LEFT JOIN price p ON p.datex = t.datex
ORDER BY 
  1 DESC;