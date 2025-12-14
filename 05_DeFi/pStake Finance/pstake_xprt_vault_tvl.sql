/* Description: Calculate vault TVL by multiplying weekly price with vault total value locked */
WITH 
  -- Get the last known price for each week
  price AS (
    SELECT 
      date_trunc('DAY', hour) AS week,  -- Renamed 'weeek' to 'week' for consistency
      LAST_VALUE(median_price) OVER (ORDER BY hour DESC) AS price
    FROM 
      dex."view_token_prices"
    WHERE 
      contract_address = '\x45e007750Cc74B1D2b4DD7072230278d9602C499')
  ,

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
        contract_address = '\x45e007750Cc74B1D2b4DD7072230278d9602C499'
      GROUP BY 1
      ORDER BY 1 ASC) a
    ORDER BY 1 DESC)
  
SELECT 
  t.datex, 
  "Vault Total Value Locked" * price AS "Vault $TVL"  -- Renamed 'price' to 'price' for consistency
FROM 
  tokens t
  LEFT JOIN price p ON p.week = t.datex  -- Renamed 'week' to 'week' for consistency