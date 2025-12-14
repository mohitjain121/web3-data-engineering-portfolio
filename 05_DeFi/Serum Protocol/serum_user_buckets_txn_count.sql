/* Description: Count transactions by wallet and bucket transactions by count */
WITH users AS 
(
    SELECT
        account_keys[0] AS wallets,
        COUNT(id) AS count_txns
    FROM `solana`.`transactions`
    WHERE 
        (array_contains(instructions.executing_account, '9xQeWvG816bUx9EPjHmaT23yvVM2ZWbrrpZb9PusVFin')
        OR array_contains(instructions.executing_account, 'EUqojwWA2rd19FZrzeBncJsm38Jm1hEhE3zsmX3bRc2o')
        OR array_contains(instructions.executing_account, 'BJ3jrUzddfuSrZHXSCxMUUQsjKEyLmuuyZebkcaFp2fg')
        ) 
        AND success = 'TRUE'
        GROUP BY 1
)

SELECT 
    COUNT(wallets) AS `Bucket`,
    SUM(CASE WHEN count_txns < 10 THEN 1 ELSE 0 END) AS `0-10`,
    SUM(CASE WHEN count_txns >= 10 AND count_txns < 25 THEN 1 ELSE 0 END) AS `10 - 25`,
    SUM(CASE WHEN count_txns >= 25 AND count_txns < 50 THEN 1 ELSE 0 END) AS `25 - 50`,
    SUM(CASE WHEN count_txns >= 50 AND count_txns < 100 THEN 1 ELSE 0 END) AS `50 - 100`,
    SUM(CASE WHEN count_txns >= 100 AND count_txns < 200 THEN 1 ELSE 0 END) AS `100 - 200`,
    SUM(CASE WHEN count_txns >= 200 THEN 1 ELSE 0 END) AS `>200`
FROM users