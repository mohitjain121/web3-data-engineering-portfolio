/* Description: Calculate project metrics */

projects AS (
SELECT
    project,
    funded,
    allocations * 13 AS eth_allocation,
    allocations * 13 * (1 - (tokens_sold / tokens_held)) AS current_allocation,
    investment_subcategory,
    tokens_held AS total_tokens_bought,
    tokens_sold,
    tokens_held - tokens_sold AS current_held,
    current_price,
    (cast(tokens_held as double) - cast(tokens_sold as double))*(cast(current_price as double)) as token_current_value,
    --cast(((tokens_held - tokens_sold)*current_price) AS double) AS c,
    yield_gen_to_date,
    token_address,
    eth_raised_sell
FROM cult_master
WHERE investment_subcategory = 'Liquid'
),

average_cult_price AS (
SELECT 
    block_date AS datex,
    cast('0xf0f9d895aca5c8678f706fb8216fa22957685a13' as varchar) as contract_address,
    cast('CULT' AS VARCHAR) AS symbol,
    lastest_cult_price as cult_price
FROM (
SELECT * FROM (
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
) AS CULTSOLD
ORDER BY datex desc
LIMIT 1
),

lasted_cult_price AS (
SELECT cult_price FROM average_cult_price
),

weth_average_price AS (
SELECT 
    cast(hour as date) AS datex,
    cast('0xc02aaa39b223fe8d0a0e5c4f27ead9083c756cc2' as varchar) as contract_address,
    cast('WETH' AS VARCHAR) AS symbol,
    AVG(median_price) AS eth_price 
FROM dex.prices
WHERE blockchain = 'ethereum'
GROUP BY 1,2,3
ORDER BY cast(hour as date) DESC
LIMIT 1
),

lasted_weth_price AS (
SELECT eth_price FROM weth_average_price
),

metrics AS (
SELECT
    'Status' AS stats,
    SUM(eth_allocation) AS initial_eth_allocation,
    SUM(eth_allocation) * (SELECT * FROM lasted_weth_price) AS initial_eth_allocation_current_usd_value,
    SUM(current_allocation) AS remaining_allocation,
    SUM(current_allocation) * (SELECT * FROM lasted_weth_price) AS remaining_allocation_current_usd_value,
    sum(token_current_value) AS tokens_estimated_current_value,
   -- SUM(((current_held) * current_price))  AS total_current_value,
    --SUM(current_value) AS current_value,
    --(SUM(current_value) - SUM(current_allocation)) / SUM(current_allocation) * 100 AS roi,
    SUM(eth_raised_sell) AS eth_raised,
    SUM(eth_raised_sell) * (SELECT * FROM lasted_weth_price) AS eth_raised_current_usd_value
    
FROM projects
--GROUP BY 1,2,3
),

metrics2 AS (
SELECT 
    stats,
    (remaining_allocation/initial_eth_allocation) AS holding,
    1-(remaining_allocation/initial_eth_allocation) AS sold,
    initial_eth_allocation,
    initial_eth_allocation_current_usd_value,
    (eth_raised + (tokens_estimated_current_value/(SELECT * FROM lasted_weth_price))) AS eth_raised_potential,
    ((eth_raised + (tokens_estimated_current_value/(SELECT * FROM lasted_weth_price)))*(SELECT * FROM lasted_weth_price)) as eth_raised_potential_current_usd_value,
    remaining_allocation AS eth_allocation_holding_initial_value,
    (tokens_estimated_current_value/(SELECT * FROM lasted_weth_price)) AS eth_allocation_holding_current_value,
    remaining_allocation_current_usd_value, 
    tokens_estimated_current_value,
    ((1-(remaining_allocation/initial_eth_allocation)) * initial_eth_allocation) AS eth_allocation_sold_initial_value,
    eth_raised as eth_allocation_sold_current_value,
    eth_raised_current_usd_value
FROM metrics
),

final_metrics AS (
SELECT 
    stats,
    holding,
    sold,
    initial_eth_allocation,
    initial_eth_allocation_current_usd_value,
    eth_raised_potential,
    eth_raised_potential_current_usd_value,
    eth_allocation_holding_initial_value,
    eth_allocation_holding_current_value,
    remaining_allocation_current_usd_value, 
    tokens_estimated_current_value,
    eth_allocation_sold_initial_value,
    eth_allocation_sold_current_value,
    eth_raised_current_usd_value,
    (eth_allocation_sold_current_value/initial_eth_allocation) as current_roi,
    ((eth_allocation_sold_current_value/initial_eth_allocation)*100) as roi,
    (eth_allocation_sold_current_value/initial_eth_allocation) as current_X,
    (eth_raised_potential/initial_eth_allocation) as potential_roi,
    ((eth_raised_potential/initial_eth_allocation)*100) as p_roi,
    (eth_raised_potential/initial_eth_allocation) as potential_X
 
FROM metrics2
)

SELECT * FROM final_metrics