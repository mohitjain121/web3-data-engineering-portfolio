/* Description: Extract Solana DEX breakdown and count transactions within the last 30 days. */
SELECT
    `block_date` AS datex,
    CASE 
        WHEN array_contains(account_keys, '675kPX9MHTjS2zt1qfr1NYHuzeLXfQM9H24wFSUt1Mp8') 
            THEN 'Raydium'
        WHEN array_contains(account_keys, '9W959DqEETiGZocYWCQPaJ6sBmUzgfxXfqGeTEdp3aQP') 
            THEN 'Orca'
        WHEN array_contains(account_keys, '9wFFyRfZBsuAha4YcuxcXLKwMxJR43S7fPfQLusDBzvT') 
            THEN 'Serum'
        WHEN array_contains(account_keys, 'dammHkt7jmytvbS3nHTxQNEcP59aE57nxwV21YdqEDN') 
            THEN 'Drift'
        WHEN array_contains(account_keys, 'mv3ekLzLbnVPNxjSKvqBpU3ZeZXPQdEC3bp5MDEBG68') 
            THEN 'Mango'
        ELSE "Others"
    END AS Solana_DEX_Breakdown,
    COUNT(id) AS count_dex
FROM `solana`.`transactions`
WHERE `block_date` > CURRENT_DATE - INTERVAL '30 DAYS'
    AND success = TRUE
GROUP BY `block_date`, 
         CASE 
             WHEN array_contains(account_keys, '675kPX9MHTjS2zt1qfr1NYHuzeLXfQM9H24wFSUt1Mp8') 
                 THEN 'Raydium'
             WHEN array_contains(account_keys, '9W959DqEETiGZocYWCQPaJ6sBmUzgfxXfqGeTEdp3aQP') 
                 THEN 'Orca'
             WHEN array_contains(account_keys, '9wFFyRfZBsuAha4YcuxcXLKwMxJR43S7fPfQLusDBzvT') 
                 THEN 'Serum'
             WHEN array_contains(account_keys, 'dammHkt7jmytvbS3nHTxQNEcP59aE57nxwV21YdqEDN') 
                 THEN 'Drift'
             WHEN array_contains(account_keys, 'mv3ekLzLbnVPNxjSKvqBpU3ZeZXPQdEC3bp5MDEBG68') 
                 THEN 'Mango'
             ELSE "Others"
         END
ORDER BY `block_date`, 
         COUNT(id)