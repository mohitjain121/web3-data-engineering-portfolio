/* Description: Calculate the average vault TVL by week */
WITH 
  -- Calculate the last price for each week
  price AS (
    SELECT 
      date_trunc('DAY', minute) AS week,  -- Renamed 'weeek' to 'week' for consistency
      LAST_VALUE(price) OVER (ORDER BY minute DESC) AS price
    FROM 
      prices."layer1_usd"
    WHERE 
      symbol = 'ATOM'
  ),
  
  -- Calculate the total value locked for each vault
  tokens AS (
    SELECT 
      datex,
      SUM("Net Asset Change Weekly") OVER (ORDER BY datex ASC) AS "Vault Total Value Locked"
    FROM (
      SELECT 
        date_trunc('DAY', evt_block_time) AS datex,
        SUM(CASE 
                WHEN "from" = '\x0000000000000000000000000000000000000000' THEN value/10^6 
                WHEN "to" = '\x0000000000000000000000000000000000000000' THEN -value/10^6 
                ELSE NULL END) AS "Net Asset Change Weekly"
      FROM 
        erc20."ERC20_evt_Transfer"
      WHERE 
        contract_address = '\x44017598f2AF1bD733F9D87b5017b4E7c1B28DDE'
      GROUP BY 
        1  -- Renumbered group by clause for consistency
      ORDER BY 
        1 ASC
    ) a
    ORDER BY 
      1 DESC  -- Renumbered order by clause for consistency
  )

SELECT 
  t.datex,
  AVG("Vault Total Value Locked" * price) AS "Vault $TVL"
FROM 
  tokens t
  LEFT JOIN 
  price p ON p.week = t.datex  -- Renamed 'weeek' to 'week' for consistency
GROUP BY 
  1  -- Renumbered group by clause for consistency
ORDER BY 
  1 DESC  -- Renumbered order by clause for consistency