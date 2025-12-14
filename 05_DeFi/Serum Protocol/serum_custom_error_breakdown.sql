/* Description: Extract custom error breakdown and count of failed transactions for specific accounts within the last 6 weeks. */

SELECT
    /* Extract custom error breakdown from error messages */
    CASE 
        WHEN CAST(error.message AS string) ILIKE "%custom%" THEN 
            RTRIM('}', LTRIM('"{"Custom":', error.message))
        ELSE NULL
    END AS Custom_Error_Breakdown,
    
    /* Count of failed transactions */
    COUNT(id) AS count_id
FROM 
    `solana`.`transactions`
WHERE 
    /* Filter transactions for specific accounts */
    (array_contains(account_keys, '9xQeWvG816bUx9EPjHmaT23yvVM2ZWbrrpZb9PusVFin')
     OR array_contains(account_keys, 'EUqojwWA2rd19FZrzeBncJsm38Jm1hEhE3zsmX3bRc2o')
     OR array_contains(account_keys, 'BJ3jrUzddfuSrZHXSCxMUUQsjKEyLmuuyZebkcaFp2fg'))
    AND 
    /* Filter transactions within the last 6 weeks */
    block_date > NOW() - INTERVAL '6 WEEKS'
    AND 
    /* Filter failed transactions */
    success = FALSE
GROUP BY 
    /* Group by the extracted custom error breakdown */
    1
ORDER BY 
    /* Order by the count of failed transactions in descending order */
    2 DESC