/* Description: Count transactions by Raydium pool */
SELECT 
    block_date AS datex,
    CASE 
        WHEN array_contains(account_keys, '58oQChx4yWmvKdwLLZzBi4ChoCc2fqCUWBkwMihLYQo2') THEN 'SOL-USDC'
        WHEN array_contains(account_keys, 'AVs9TA4nWDzfPJE9gGVNJMVhcQy3V9PGazuz33BfG2RA') THEN 'RAY-SOL'
        WHEN array_contains(account_keys, '6UmmUiYoBjSrhakAobJw8BvkmJtDVxaeBtbt7rxWo1mg') THEN 'RAY-USDC'
        WHEN array_contains(account_keys, '8iQFhWyceGREsWnLM8NkG9GC8DvZunGZyMzuyUScgkMK') THEN 'RAY-soETH'
        WHEN array_contains(account_keys, 'DVa7Qmb5ct9RCpaU7UTpSaf3GVMYz17vNVU67XpdCRut') THEN 'RAY-USDT'
        WHEN array_contains(account_keys, 'GaqgfieVmnmY4ZsZHHA6L5RSVzCGL3sKx4UgHBaYNy8m') THEN 'RAY-SRM'
        WHEN array_contains(account_keys, '7XawhbbxtsRcQA8KTkHT9f9nc6d69UwqCDh6U5EEbEmX') THEN 'SOL-USDT'
        WHEN array_contains(account_keys, 'Enq8vJucRbkzKA1i1PahJNhMyUTzoVL5Cs8n5rC3NLGn') THEN 'GENE-USDC'
        WHEN array_contains(account_keys, '2EXiumdi14E9b8Fy62QcA5Uh6WdHS2b38wtSxp72Mibj') THEN 'USDT-USDC'
        WHEN array_contains(account_keys, '6a1CsrpeZubDjEJE9s1CMVheB6HWM5d7m1cj2jkhyXhj') THEN 'stSOL-USDC'
        WHEN array_contains(account_keys, '4yrHms7ekgTBgJg77zJ33TsWrraqHsCXDtuSZqUsuGHb') THEN 'ETH-SOL'
        WHEN array_contains(account_keys, 'F73euqPynBwrgcZn3fNSEneSnYasDQohPM5aZazW9hp2') THEN 'ATLAS-RAY'
        WHEN array_contains(account_keys, '9euZD3C1d7e2fLKnUxHc7oUUDJcYnguMT6cRzLY9y4o7') THEN 'stSOL-USDT'
        WHEN array_contains(account_keys, '9f4FtV6ikxUZr8fAjKSGNPPnUHJEwi4jNk8d79twbyFf') THEN 'stSOL-SOL'
        WHEN array_contains(account_keys, '5NLeMabMyuJQUbvXNfVyUPbtYKwTXBesfmFmDswbgqUz') THEN 'GST-USDC'
        WHEN array_contains(account_keys, 'ZfvDXXUhZDzDVsapffUyXHj9ByCoPjP4thL6YXcZ9ix') THEN 'mSOL-USDC'
        WHEN array_contains(account_keys, 'EoNrn8iUhwgJySD1pHu8Qxm5gSQqLK3za4m8xzD2RuEb') THEN 'ETH-USDC'
        WHEN array_contains(account_keys, '6tmFJbMk5yVHFcFy7X2K8RwHjKLr6KVFLYXpgpBNeAxB') THEN 'UXP-USDC'
        WHEN array_contains(account_keys, '8idN93ZBpdtMp4672aS4GGMDy7LdVWCCXH7FKFdMw9P4') THEN 'SLIM-SOL'
        WHEN array_contains(account_keys, '8FrCybrh7UFznP1hVHg8kXZ8bhii37c7BGzmjkdcsGJp') THEN 'GENE-RAY'
        
        END AS Raydium_Pool,
    COUNT(id) AS count_txns
FROM `solana`.`transactions`
WHERE 
    block_date > NOW() - INTERVAL '1 MONTH'
    AND (
        array_contains(account_keys, '675kPX9MHTjS2zt1qfr1NYHuzeLXfQM9H24wFSUt1Mp8')
        -- OR array_contains(account_keys, 'routeUGWgWzqBWFcrCfv8tritsqukccJPu3q5GPP3xS')
        -- OR array_contains(account_keys, 'EhhTKczWMGQt46ynNeRX1WfeagwwJd7ufHvCDjRxjo5Q')
        -- OR array_contains(account_keys, '9KEPoZmtHUrBbhWN1v1KWLMkkvwY6WLtAVUCPRtRjP4z')
        -- OR array_contains(account_keys, '9HzJyW1qZsEiSfMUf6L2jo3CcTKAyBmSyKdwQeYisHrC')
    )
    AND success = TRUE
GROUP BY 1, 2
ORDER BY count_txns DESC;