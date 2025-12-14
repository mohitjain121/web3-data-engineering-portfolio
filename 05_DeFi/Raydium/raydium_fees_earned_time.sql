/* Description: Calculate total and average fees for specific accounts within the last 90 days. */

SELECT 
    block_date AS datex,
    SUM(fee) / 1e9 AS `Total Fees`,
    AVG(fee) / 1e9 AS `Average Fees`
FROM `solana`.`transactions`
WHERE 
    (
        array_contains(account_keys, '675kPX9MHTjS2zt1qfr1NYHuzeLXfQM9H24wFSUt1Mp8')
        OR array_contains(account_keys, 'routeUGWgWzqBWFcrCfv8tritsqukccJPu3q5GPP3xS')
        OR array_contains(account_keys, 'EhhTKczWMGQt46ynNeRX1WfeagwwJd7ufHvCDjRxjo5Q')
        OR array_contains(account_keys, '9KEPoZmtHUrBbhWN1v1KWLMkkvwY6WLtAVUCPRtRjP4z')
        OR array_contains(account_keys, '9HzJyW1qZsEiSfMUf6L2jo3CcTKAyBmSyKdwQeYisHrC')
    )
    AND block_date > NOW() - INTERVAL '90 DAYS'
GROUP BY 1