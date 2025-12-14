/* Description: Retrieve Serum transactions for specific accounts within the last 6 weeks. */

SELECT 
    CONCAT('<a href="https://solscan.io/account/', account_keys[0], '" target="_blank" >', account_keys[0], '</a>') AS user_id, 
    COUNT(`id`) AS number_of_serum_transactions
FROM `solana`.`transactions`
WHERE 
    (array_contains(account_keys, '9xQeWvG816bUx9EPjHmaT23yvVM2ZWbrrpZb9PusVFin')
    OR array_contains(account_keys, 'EUqojwWA2rd19FZrzeBncJsm38Jm1hEhE3zsmX3bRc2o')
    OR array_contains(account_keys, 'BJ3jrUzddfuSrZHXSCxMUUQsjKEyLmuuyZebkcaFp2fg')
    )
    AND block_time >= NOW() - INTERVAL '6 WEEKS'
GROUP BY 1
ORDER BY 2 DESC
LIMIT 100;