/* Description: Calculate investment metrics for cult_master table */
SELECT 
    project,
    guardian_sponsor,
    tokens_sold / tokens_held AS inv_sold,  -- token inventory sold
    tokens_sold,
    allocations * 13 / tokens_held AS start_price_token,  -- start price of token
    eth_raised_sell / tokens_sold AS sale_price_token,  -- sale price of token
    eth_raised_sell - allocations * 13 * (tokens_sold / tokens_held) AS eth_pnl,  -- profit/loss in ETH
    (eth_raised_sell - allocations * 13 * (tokens_sold / tokens_held)) / (allocations * 13 * (tokens_sold / tokens_held)) AS percent_profit  -- percentage profit
FROM cult_master
WHERE 
    investment_subcategory IN ('Liquid')  -- filter by investment subcategory
AND tokens_sold != 0  -- exclude rows with zero tokens sold
ORDER BY percent_profit DESC  -- sort by percentage profit in descending order