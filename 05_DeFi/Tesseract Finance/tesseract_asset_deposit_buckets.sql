/* Description: Calculate USDC deposits by amount range */

WITH 
  price AS (
    SELECT price 
    FROM prices."usd"
    WHERE "contract_address" = '\x2791bca1f2de4661ed88a30c99a7a9449aa84174'
    ORDER BY minute DESC
    LIMIT 1
  ),
  usdc AS (
    SELECT 
      "from", 
      SUM(value) / 1e6 AS amount 
    FROM 
      erc20."ERC20_evt_Transfer"
    WHERE 
      "to" = '\x57bDbb788d0F39aEAbe66774436c19196653C3F2'  --USDC
    GROUP BY 1
  ),
  usdc_deposits AS (
    SELECT 
      usdc.amount * price AS deposit 
    FROM 
      usdc 
      CROSS JOIN price
  )
SELECT 
  COUNT(deposit),
  SUM(CASE WHEN deposit < 100 THEN 1 ELSE 0 END) AS "<$100",
  SUM(CASE WHEN deposit >= 100 AND deposit < 250 THEN 1 ELSE 0 END) AS "$100 - $250",
  SUM(CASE WHEN deposit >= 250 AND deposit < 500 THEN 1 ELSE 0 END) AS "$250 - $500",
  SUM(CASE WHEN deposit >= 500 AND deposit < 1000 THEN 1 ELSE 0 END) AS "$500 - $1000",
  SUM(CASE WHEN deposit >= 1000 AND deposit < 10000 THEN 1 ELSE 0 END) AS "$1000 - $10000",
  SUM(CASE WHEN deposit >= 10000 THEN 1 ELSE 0 END) AS ">$10000"
FROM 
  usdc_deposits;