/* Description: Extract failed program names and error counts from recent Solana transactions. */

SELECT
    SUBSTRING_INDEX(SUBSTR(log_messages[size(log_messages)-1], 9), ' ', 1) AS program_failed,
    COUNT(id) AS count_error
FROM `solana`.`transactions`
WHERE 
    (array_contains(account_keys, '9xQeWvG816bUx9EPjHmaT23yvVM2ZWbrrpZb9PusVFin')
    OR array_contains(account_keys, 'EUqojwWA2rd19FZrzeBncJsm38Jm1hEhE3zsmX3bRc2o')
    OR array_contains(account_keys, 'BJ3jrUzddfuSrZHXSCxMUUQsjKEyLmuuyZebkcaFp2fg'))
    AND block_date > NOW() - INTERVAL '6 WEEKS'
    AND success = FALSE
GROUP BY program_failed
ORDER BY count_error DESC
LIMIT 10;