/* Description: Calculate vault TVL and share price */
WITH 
  -- Calculate daily vault price per share
  vault_price_per_share AS (
    SELECT 
      date_trunc('DAY', call_block_time) AS datex,
      AVG(output_0 / POWER(10, 18)) AS price
    FROM 
      yearn_v2."yVault_call_pricePerShare"
    WHERE 
      contract_address = '\xdCD90C7f6324cfa40d7169ef80b12031770B4325'
      AND call_success = TRUE
    GROUP BY 1
  ),
  
  -- Calculate daily token price
  token_price AS (
    SELECT 
      date_trunc('DAY', minute) AS datex,
      AVG(price) AS price
    FROM 
      prices."usd"
    WHERE 
      symbol = 'WETH'
    GROUP BY 1
  ),
  
  -- Calculate daily price by multiplying token price with vault price per share
  price AS (
    SELECT 
      t.datex,
      t.price * v.price AS price
    FROM 
      token_price t
      INNER JOIN vault_price_per_share v ON t.datex = v.datex
  ),
  
  -- Calculate daily vault tokens
  tokens AS (
    SELECT 
      datex,
      SUM(CASE 
              WHEN "from" = '\x97990b693835da58a281636296d2bf02787dea17' THEN -value / POWER(10, 18) 
              WHEN "to" = '\x97990b693835da58a281636296d2bf02787dea17' THEN value / POWER(10, 18) 
              ELSE NULL END) AS "Vault Tokens"
    FROM 
      erc20."ERC20_evt_Transfer"
    WHERE 
      contract_address = '\xdCD90C7f6324cfa40d7169ef80b12031770B4325'
    GROUP BY 1
    ORDER BY 1 ASC
  )

SELECT 
  t.datex,
  "Vault Tokens",
  p.price AS "Share Price",
  "Vault Tokens" * p.price AS "Vault $TVL"
FROM 
  tokens t
  LEFT JOIN price p ON p.datex = t.datex
WHERE 
  "Vault Tokens" * p.price IS NOT NULL