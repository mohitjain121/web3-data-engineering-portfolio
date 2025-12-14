/* Description: Count unique wallets deposited or withdrawn within the last 7 days. */

SELECT 
    COUNT(DISTINCT wallet) AS "total_unique_wallets"
FROM 
    (
    SELECT 
        DISTINCT wallet 
    FROM 
        idex_v3."exchange_v3_1_evt_deposited"
    WHERE 
        date_trunc('day', evt_block_time) > CURRENT_DATE - INTERVAL '7 days'
    UNION
    SELECT 
        DISTINCT wallet 
    FROM 
        idex_v3."exchange_v3_1_evt_withdrawn"
    WHERE 
        date_trunc('day', evt_block_time) > CURRENT_DATE - INTERVAL '7 days'
    ) x