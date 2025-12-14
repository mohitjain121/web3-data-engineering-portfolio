/* Description: Extracts daily transaction data for specific accounts with failed transactions. */
SELECT 
    date_trunc('DAY', block_time) AS datex,
    REGEXP_EXTRACT(CAST(log_messages AS string), 'Instruction:(.*?),') AS instruction_executed,
    COUNT(id) AS id_count
FROM `solana`.`transactions`
WHERE block_date > NOW() - INTERVAL '6 WEEKS'
  AND (
    array_contains(account_keys, '9xQeWvG816bUx9EPjHmaT23yvVM2ZWbrrpZb9PusVFin')
    OR array_contains(account_keys, 'EUqojwWA2rd19FZrzeBncJsm38Jm1hEhE3zsmX3bRc2o')
    OR array_contains(account_keys, 'BJ3jrUzddfuSrZHXSCxMUUQsjKEyLmuuyZebkcaFp2fg')
  )
  AND success = FALSE
GROUP BY 1, 2
ORDER BY id_count DESC;