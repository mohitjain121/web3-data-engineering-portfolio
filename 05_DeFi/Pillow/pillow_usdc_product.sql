/* Description: Calculate USDX deposits and users on Ethereum and Binance Smart Chain. */

WITH 
usdx_eth AS (
  SELECT 
    SUM(value) / 1e6 AS usdx_on_eth,
    COUNT(DISTINCT `from`) AS usdx_users_on_eth
  FROM 
    erc20_ethereum.evt_Transfer
  WHERE 
    `to` = LOWER('0xe9BB903eB69972294686AEE93C1ed8749eC372Ad')  -- deposit contract
    AND contract_address IN (
      LOWER('0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48'), 
      LOWER('0xdAC17F958D2ee523a2206206994597C13D831ec7')
    )
    AND evt_block_time >= '2021-11-01'
),

usdx_bsc AS (
  SELECT 
    SUM(value) / 1e18 AS usdx_on_bsc,
    COUNT(DISTINCT `from`) AS usdx_users_on_bsc
  FROM 
    erc20_bnb.evt_Transfer
  WHERE 
    `to` = LOWER('0xbAB05bCDbfBd9A5586134f0abf4afb7447206dad')  -- deposit contract
    AND contract_address IN (
      LOWER('0x8AC76a51cc950d9822D68b83fE1Ad97B32Cd580d'), 
      LOWER('0x55d398326f99059fF775485246999027B3197955')
    )
    AND evt_block_time >= '2021-11-01'
),

usdx_eth_with AS (
  SELECT 
    SUM(value) / 1e6 AS usdx_on_eth_with,
    COUNT(DISTINCT `to`) AS usdx_users_on_eth_with
  FROM 
    erc20_ethereum.evt_Transfer
  WHERE 
    `from` = LOWER('0xbAB05bCDbfBd9A5586134f0abf4afb7447206dad')  -- deposit contract
    AND contract_address IN (
      LOWER('0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48'), 
      LOWER('0xdAC17F958D2ee523a2206206994597C13D831ec7')
    )
    AND evt_block_time >= '2021-11-01'
),

usdx_bsc_with AS (
  SELECT 
    SUM(value) / 1e18 AS usdx_on_bsc_with,
    COUNT(DISTINCT `to`) AS usdx_users_on_bsc_with
  FROM 
    erc20_bnb.evt_Transfer
  WHERE 
    `from` = LOWER('0xbAB05bCDbfBd9A5586134f0abf4afb7447206dad')  -- deposit contract
    AND contract_address IN (
      LOWER('0x8AC76a51cc950d9822D68b83fE1Ad97B32Cd580d'), 
      LOWER('0x55d398326f99059fF775485246999027B3197955')
    )
    AND evt_block_time >= '2021-11-01'
),

-- Calculate total USDX deposits and users
total_usdx AS (
  SELECT 
    usdx_on_bsc + usdx_on_eth AS usdx_dep,
    usdx_users_on_bsc + usdx_users_on_eth AS users_usdx_dep,
    usdx_on_bsc_with + usdx_on_eth_with AS usdx_with,
    usdx_users_on_bsc_with + usdx_users_on_eth_with AS users_usdx_with
  FROM 
    usdx_eth, usdx_bsc, usdx_bsc_with, usdx_eth_with
)

SELECT 
  usdx_dep,
  users_usdx_dep,
  usdx_with,
  users_usdx_with
FROM 
  total_usdx;