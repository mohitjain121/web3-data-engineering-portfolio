/* Description: Daily Uniswap Perps swaps and volume */
SELECT 
    date_trunc('day', t1."block_time") AS day,
    CASE 
        WHEN p1."evt_tx_hash" IS NOT NULL THEN 'Uniswap - Perps' 
        ELSE "project" 
    END AS project,
    SUM(1) AS swaps,
    SUM(usd_amount) AS usd_amount
FROM 
    dex."trades" t1
LEFT JOIN 
    perp_v2."ClearingHouse_evt_PositionChanged" p1
ON 
    p1."contract_address" = t1."trader_a"
    AND p1."evt_tx_hash" = t1."tx_hash"
    AND p1."evt_block_time" = t1."block_time"
WHERE 
    "block_time" >= '2022-05-01 00:00' 
    AND "block_time" < '2022-07-01 00:00'
    AND "category" = 'DEX'
    AND p1."evt_tx_hash" IS NULL
GROUP BY 
    date_trunc('day', t1."block_time"),
    CASE 
        WHEN p1."evt_tx_hash" IS NOT NULL THEN 'Uniswap - Perps' 
        ELSE "project" 
    END;