/* Description: Extract Serum V1, V2, V3, and Total transaction counts from Solana transactions. */
SELECT
    block_date, 
    SUM(CASE 
            WHEN instruction['executing_account'] = '9xQeWvG816bUx9EPjHmaT23yvVM2ZWbrrpZb9PusVFin' THEN 1 ELSE 0 END) AS `serum_v3`,
    SUM(CASE 
            WHEN instruction['executing_account'] = 'EUqojwWA2rd19FZrzeBncJsm38Jm1hEhE3zsmX3bRc2o' THEN 1 ELSE 0 END) AS `serum_v2`,
    SUM(CASE 
            WHEN instruction['executing_account'] = 'BJ3jrUzddfuSrZHXSCxMUUQsjKEyLmuuyZebkcaFp2fg' THEN 1 ELSE 0 END) AS `serum_v1`,
    SUM(CASE 
            WHEN instruction['executing_account'] = '9xQeWvG816bUx9EPjHmaT23yvVM2ZWbrrpZb9PusVFin' THEN 1
            WHEN instruction['executing_account'] = 'EUqojwWA2rd19FZrzeBncJsm38Jm1hEhE3zsmX3bRc2o' THEN 1
            WHEN instruction['executing_account'] = 'BJ3jrUzddfuSrZHXSCxMUUQsjKEyLmuuyZebkcaFp2fg' THEN 1 ELSE 0 END) AS `serum_total`
FROM `solana`.`transactions`
LATERAL VIEW explode(instructions) instructions AS instruction
WHERE block_date >= now() - interval '6 WEEKS'
    AND success = TRUE
GROUP BY 1
ORDER BY 1 DESC;