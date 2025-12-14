/* Description: Calculate vault TVL and share price for a given time period */
WITH 
  -- Calculate daily vault price per share
  vault_price_per_share AS (
    SELECT 
      date_trunc('DAY', call_block_time) AS datex,
      AVG(output_0 / POWER(10, 18)) AS price
    FROM 
      yearn_v2."yVault_call_pricePerShare"
    WHERE 
      contract_address = '\xdA816459F1AB5631232FE5e97a05BBBb94970c95'
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
      symbol = 'DAI'
    GROUP BY 1
  ),
  
  -- Calculate daily share price
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
              WHEN "from" = '\x0000000000000000000000000000000000000000' THEN value / POWER(10, 18)
              WHEN "to" = '\x0000000000000000000000000000000000000000' THEN -value / POWER(10, 18)
              ELSE NULL END) AS "Vault Tokens"
    FROM 
      erc20."ERC20_evt_Transfer"
    WHERE 
      contract_address = '\xdA816459F1AB5631232FE5e97a05BBBb94970c95'
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
  AND t.datex BETWEEN '2021-07-01 00:00:00' AND '2021-12-31 23:59:59'
ORDER BY 1 DESC;