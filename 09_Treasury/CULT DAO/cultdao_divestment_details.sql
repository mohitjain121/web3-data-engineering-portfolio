/* Description: Extracts relevant investment data from the cult_master table. */

SELECT 
    project,
    allocations * 13 AS eth_allocation,
    tokens_held AS total_tokens_bought,
    tokens_sold,
    tokens_held - tokens_sold AS current_held,
    eth_raised_sell
FROM 
    cult_master
WHERE 
    investment_subcategory IN ('Liquid')
    AND tokens_sold != 0
ORDER BY 
    eth_raised_sell DESC