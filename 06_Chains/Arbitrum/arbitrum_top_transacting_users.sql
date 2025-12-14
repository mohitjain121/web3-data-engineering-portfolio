/* Description: Extract user and transaction count from arbitrum transactions */
SELECT 
    CONCAT('<a href="https://arbiscan.io/address/', `from`, '" target="_blank" >', `from`, '</a>') AS user,
    COUNT(DISTINCT `hash`) AS num_txns
FROM 
    arbitrum.transactions
WHERE 
    -- `from` NOT IN (SELECT DISTINCT contract_address FROM arbitrum.logs)
    1 = 1  -- commented out condition
GROUP BY 
    CONCAT('<a href="https://arbiscan.io/address/', `from`, '" target="_blank" >', `from`, '</a>')
ORDER BY 
    num_txns DESC
LIMIT 100