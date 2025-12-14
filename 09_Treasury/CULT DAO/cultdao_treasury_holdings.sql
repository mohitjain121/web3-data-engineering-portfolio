/* Description: Calculate holdings in ETH and USD for a specific token address */

WITH 
  -- Get the latest CULT price for the given contract address
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
        WHERE (cast(token_bought_address as varchar) = '0xf0f9d895aca5c8678f706fb8216fa22957685a13')
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
        WHERE (cast(token_sold_address as varchar) = '0xf0f9d895aca5c8678f706fb8216fa22957685a13')
        AND (cast(token_bought_address as varchar) = '0xc02aaa39b223fe8d0a0e5c4f27ead9083c756cc2')
        AND (token_sold_symbol = 'CULT')
        AND (token_bought_symbol = 'WETH')
        AND (token_sold_amount > 10)
        ORDER BY block_time desc
      )
      ORDER BY block_time desc
    )
    GROUP BY 1,2,3
    ORDER BY datex DESC
  ),

  -- Get the average WETH price
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

  -- Get the holdings for the given token address
  holdings AS (
    SELECT
      datex,
      contract_address AS token_address,
      SUM(amount) AS token_change,
      SUM(SUM(amount)) OVER ( ORDER BY datex ) AS holding
    FROM
      (
        SELECT
          cast(evt_block_time AS date) AS datex,
          contract_address,
          (((-1) * cast(value AS DOUBLE) ) / 1000000000000000000 ) AS amount
        FROM erc20_ethereum.evt_Transfer
        WHERE cast(contract_address AS varchar) = '0xf0f9d895aca5c8678f706fb8216fa22957685a13'
        AND cast("from" AS VARCHAR) = '0x55ac81186e1a8454c79ad78c615c43f54f87403b'
        UNION ALL
        SELECT
          cast(evt_block_time AS DATE) AS datex,
          contract_address,
          (cast(value AS DOUBLE) / 1000000000000000000 ) AS amount 
        FROM erc20_ethereum.evt_Transfer
        WHERE cast(contract_address AS VARCHAR) = '0xf0f9d895aca5c8678f706fb8216fa22957685a13'
        AND cast("to" AS VARCHAR) = '0x55ac81186e1a8454c79ad78c615c43f54f87403b'
      ) x
    GROUP BY
      1,
      2
    ORDER BY datex DESC
  ),

  -- Join the holdings with the average CULT and WETH prices
  pre_final AS (
    SELECT 
      h.datex,
      h.token_address,
      h.token_change,
      h.holding,
      p.contract_address,
      p.symbol,
      p.cult_price,
      SUM(CASE WHEN p.cult_price is NULL THEN 0 ELSE 1 END) over (ORDER BY h.datex ASC) AS value_partition,
      ep.eth_price,
      SUM(CASE WHEN ep.eth_price is NULL THEN 0 ELSE 1 END) over (ORDER BY h.datex ASC) AS value_partition2
    FROM holdings h
    LEFT JOIN weth_average_price ep ON (ep.datex = h.datex)
    LEFT JOIN average_cult_price p ON (p.datex = h.datex)
  ),

  -- Fix the NULL values in the CULT price
  cult_price_fix_null AS (
    SELECT 
      datex,
      token_address,
      token_change,
      holding,
      first_value(cult_price) over (partition BY value_partition ORDER BY datex ASC) AS cult_price,
      first_value(eth_price) over (partition BY value_partition2 ORDER BY datex ASC) AS eth_price
    FROM pre_final
    ORDER BY datex DESC
  ),

  -- Calculate the holdings in USD
  holdings_usd_value AS (
    SELECT 
      datex,
      token_address,
      token_change,
      holding,
      (holding*cult_price) AS usd_holding,
      cult_price,
      eth_price
    FROM cult_price_fix_null
  ),

  -- Calculate the holdings in ETH
  holdings_eth_value AS (
    SELECT 
      datex,
      token_address,
      token_change,
      holding,
      usd_holding,
      (usd_holding/eth_price) AS eth_holdings,
      cult_price,
      eth_price
    FROM holdings_usd_value
  )

SELECT * FROM holdings_eth_value
ORDER BY datex DESC