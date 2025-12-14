/* Description: Calculate the average price of CULT and WETH, and their ratio. */

WITH 
  -- Get the average price of CULT
  average_cult_price AS (
    SELECT 
      datex,
      contract_address,
      symbol,
      AVG(cult_price) AS cult_price 
    FROM (
      SELECT 
        block_date AS datex,
        cast('0xf0f9d895aca5c8678f706fb8216fa22957685a13' as varchar) as contract_address,
        cast('CULT' AS VARCHAR) AS symbol,
        lastest_cult_price as cult_price
      FROM (
        SELECT 
          block_date,
          block_time,
          token_pair,
          amount_usd/token_bought_amount  as lastest_cult_price,
          amount_usd/token_sold_amount  as lastest_eth_price,
          blockchain,
          project,
          version
        FROM uniswap_v2_ethereum.trades
        WHERE 
          (cast(token_bought_address as varchar) = '0xf0f9d895aca5c8678f706fb8216fa22957685a13')
          AND (cast(token_sold_address as varchar) = '0xc02aaa39b223fe8d0a0e5c4f27ead9083c756cc2')
          AND (token_bought_symbol = 'CULT')
          AND (token_sold_symbol = 'WETH')
          AND (token_bought_amount > 10)
        ORDER BY block_time desc
      ) AS CULTBOUGHT
      UNION 
      SELECT * FROM (
        SELECT 
          block_date,
          block_time,
          token_pair,
          amount_usd/token_sold_amount as lastest_cult_price,
          amount_usd/token_bought_amount as lastest_eth_price,
          blockchain,
          project,
          version
        FROM uniswap_v2_ethereum.trades
        WHERE 
          (cast(token_sold_address as varchar) = '0xf0f9d895aca5c8678f706fb8216fa22957685a13')
          AND (cast(token_bought_address as varchar) = '0xc02aaa39b223fe8d0a0e5c4f27ead9083c756cc2')
          AND (token_sold_symbol = 'CULT')
          AND (token_bought_symbol = 'WETH')
          AND (token_sold_amount > 10)
        ORDER BY block_time desc
      )
    ) AS CULTSOLD
    ORDER BY datex desc
  ),
  
  -- Get the average price of WETH
  weth_average_price AS (
    SELECT 
      cast(hour as date) AS datex,
      contract_address,
      cast('WETH' AS VARCHAR) AS symbol,
      AVG(median_price) AS eth_price 
    FROM dex.prices
    WHERE blockchain = 'ethereum'
    AND cast(contract_address AS VARCHAR) = '0xc02aaa39b223fe8d0a0e5c4f27ead9083c756cc2'
    GROUP BY 1,2,3
    ORDER BY cast(hour as date) DESC
  ),
  
  -- Join the average prices of CULT and WETH
  cult_vs_eth_price AS (
    SELECT 
      cp.datex,
      cp.contract_address,
      cp.symbol,
      cp.cult_price, 
      ep.eth_price 
    FROM average_cult_price cp
    LEFT JOIN weth_average_price ep ON (ep.datex = cp.datex)
  )

SELECT 
  datex AS date,
  cult_price,
  eth_price,
  (eth_price/cult_price) AS eth_to_cult
FROM cult_vs_eth_price
ORDER BY datex DESC