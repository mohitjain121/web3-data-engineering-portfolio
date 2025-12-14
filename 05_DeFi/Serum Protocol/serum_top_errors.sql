/* Description: Count failed transactions for specific accounts within the last 6 weeks. */

SELECT
    error AS `error`,
    COUNT(id) AS count_error
FROM `solana`.`transactions`
WHERE 
    (array_contains(account_keys, '9xQeWvG816bUx9EPjHmaT23yvVM2ZWbrrpZb9PusVFin')
    OR array_contains(account_keys, 'EUqojwWA2rd19FZrzeBncJsm38Jm1hEhE3zsmX3bRc2o')
    OR array_contains(account_keys, 'BJ3jrUzddfuSrZHXSCxMUUQsjKEyLmuuyZebkcaFp2fg'))
    AND block_date > NOW() - INTERVAL '6 WEEKS'
    AND success = FALSE
GROUP BY 1
ORDER BY 2 DESC;