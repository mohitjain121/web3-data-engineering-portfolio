/* Description: Calculate average vault deposit time for a specific address */
SELECT 
    x.vault, 
    AVG(time_diff) AS "avg_vault_deposit_time" 
FROM 
(
    SELECT 
        x.vault, 
        x.address, 
        dep_time, 
        with_time, 
        DATE_PART('day', with_time - dep_time) AS time_diff 
    FROM 
    (
        SELECT 
            CONCAT(y.ytoken, ' ', y.tag) AS vault, 
            t."to" AS address, 
            MIN(evt_block_time) AS dep_time 
        FROM 
        yearn."yearn_all_vaults" y 
        INNER JOIN 
        erc20."ERC20_evt_Transfer" t ON t.contract_address = y.contract_address 
        WHERE 
            t."from" = '\x0000000000000000000000000000000000000000' 
            -- OR t."from" = '\x0000000000000000000000000000000000000001'
        GROUP BY 2, 1 
        ORDER BY 3 DESC 
    ) x 
    LEFT JOIN 
    (
        SELECT 
            CONCAT(y.ytoken, ' ', y.tag) AS vault, 
            t."from" AS address, 
            COALESCE(MIN(evt_block_time), NULL) AS with_time 
        FROM 
        yearn."yearn_all_vaults" y 
        INNER JOIN 
        erc20."ERC20_evt_Transfer" t ON t.contract_address = y.contract_address 
        WHERE 
            t."to" = '\x0000000000000000000000000000000000000000'
            -- OR t."to" = '\x0000000000000000000000000000000000000001'
        GROUP BY 2, 1 
        ORDER BY 3 DESC 
    ) y ON x.address = y.address 
    WHERE 
        with_time IS NOT NULL AND dep_time < with_time 
) x 
GROUP BY 1 
ORDER BY 2 DESC;