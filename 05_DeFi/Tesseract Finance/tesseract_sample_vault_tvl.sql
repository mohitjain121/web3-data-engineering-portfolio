/* Description: Calculate the TVL of USDC in USD */
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
      x.day_of_deposit,
      SUM(SUM(deposit)) OVER (ORDER BY x.day_of_deposit ASC) AS "Cumulative Deposits", 
      SUM(SUM(withdrawal)) OVER (ORDER BY x.day_of_deposit ASC) AS "Cumulative Withdrawals"
    FROM (
      SELECT 
        date_trunc('DAY', evt_block_time) AS day_of_deposit, 
        SUM("value"/1e6) AS deposit, 
        COUNT("to") AS users1
      FROM 
        erc20."ERC20_evt_Transfer" 
      WHERE 
        "from" = '\x0000000000000000000000000000000000000000' 
        AND "contract_address" = '\x57bDbb788d0F39aEAbe66774436c19196653C3F2' --USDC
      GROUP BY 1 
      ORDER BY 1 DESC
    ) x 
    FULL JOIN (
      SELECT 
        date_trunc('DAY', evt_block_time) AS day_of_deposit, 
        SUM("value"/1e6) AS withdrawal, 
        COUNT("from") AS users2
      FROM 
        erc20."ERC20_evt_Transfer"
      WHERE 
        "to" = '\x0000000000000000000000000000000000000000' 
        AND "contract_address" = '\x57bDbb788d0F39aEAbe66774436c19196653C3F2' --USDC
      GROUP BY 1 
      ORDER BY 1 DESC
    ) y ON x.day_of_deposit = y.day_of_deposit
    GROUP BY 1 
    ORDER BY 1 DESC
    LIMIT 1
  ),
  
  usdc_deposits AS (
    SELECT 
      usdc.vault_value * price AS tvl_usdc
    FROM 
      usdc, 
      price
  )
  
SELECT 
  tvl_usdc 
FROM 
  usdc_deposits