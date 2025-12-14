/* Description: Calculate total ETH raised, return to stakers, and burned */
SELECT 
    SUM(eth_raised_sell) AS sum_eth_raised_sell,
    -- Calculate 50% of total ETH raised for return to stakers
    SUM(eth_raised_sell) * 0.5 AS return_to_stakers,
    -- Calculate 50% of total ETH raised for burned
    SUM(eth_raised_sell) * 0.5 AS burned

FROM 
    cult_master