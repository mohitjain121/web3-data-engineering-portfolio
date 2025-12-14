/* Description: Calculate average staking time for a specific contract address */
SELECT 
    AVG(time_diff) AS "pStake Avg Atom Vault staking Time"
FROM 
(
    SELECT 
        x.address, 
        dep_time, 
        with_time, 
        DATE_PART('DAY', with_time - dep_time) AS time_diff
    FROM 
    (
        SELECT 
            "to" AS address, 
            MIN(evt_block_time) AS dep_time
        FROM 
            erc20."ERC20_evt_Transfer"
        WHERE 
            contract_address = '\x44017598f2AF1bD733F9D87b5017b4E7c1B28DDE'
        GROUP BY 
            1
    ) x 

    LEFT JOIN 

    (
        SELECT 
            "from" AS address,
            COALESCE(MIN(evt_block_time), NULL) AS with_time
        FROM 
            erc20."ERC20_evt_Transfer"
        WHERE 
            contract_address = '\x45e007750Cc74B1D2b4DD7072230278d9602C499'
        GROUP BY 
            1
    ) y 
    ON 
        x.address = y.address
    WHERE 
        with_time IS NOT NULL
    GROUP BY 
        1, 2, 3, 4
    ORDER BY 
        4 ASC
) x