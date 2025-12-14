/* Description: Calculate vault TVL and share price */
WITH 
  -- Calculate daily vault price per share
  vault_price_per_share AS (
    SELECT 
      date_trunc('DAY', call_block_time) AS datex,
      AVG(output_0 / 10^6) AS price
    FROM 
      yearn_v2."yVault_call_pricePerShare"
    WHERE 
      contract_address = '\xa354F35829Ae975e850e23e9615b11Da1B3dC4DE'
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
      symbol = 'USDC'
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
              WHEN "from" = '\x97990b693835da58a281636296d2bf02787dea17' THEN -value / 10^6 
              WHEN "to" = '\x97990b693835da58a281636296d2bf02787dea17' THEN value / 10^6 
              ELSE NULL END) AS "Vault Tokens"
    FROM 
      erc20."ERC20_evt_Transfer"
    WHERE 
      contract_address = '\xa354F35829Ae975e850e23e9615b11Da1B3dC4DE'
    GROUP BY 1
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