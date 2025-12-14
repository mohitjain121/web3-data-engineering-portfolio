/* Description: Calculate staked balances for specific tokens. */
SELECT 
    wallet, 
    vault, 
    staked_balance, 
    no_txns
FROM
(
    SELECT 
        CONCAT('<a href="https://etherscan.io/address/0', SUBSTRING("wallet"::text, 2), '" target="_blank" >', "wallet", '</a>') AS wallet, 
        vault,
        SUM(value)/10^ (CASE 
        WHEN vault = 'stkETH' THEN 18 ELSE 6 END) as staked_balance,
        COUNT(wallet) AS no_txns
    FROM
    (
        SELECT
            "from" AS wallet, -- Unstake
            (-1)*value AS value,
            CASE
                WHEN contract_address = '\x44017598f2AF1bD733F9D87b5017b4E7c1B28DDE' THEN 'stkATOM'
                WHEN contract_address = '\x45e007750Cc74B1D2b4DD7072230278d9602C499' THEN 'stkXPRT'
                WHEN contract_address = '\x2C5Bcad9Ade17428874855913Def0A02D8bE2324' THEN 'stkETH'
                ELSE 'Others' END AS vault
        FROM erc20."ERC20_evt_Transfer"
        WHERE contract_address IN ('\x44017598f2AF1bD733F9D87b5017b4E7c1B28DDE', '\x45e007750Cc74B1D2b4DD7072230278d9602C499',
        '\x2C5Bcad9Ade17428874855913Def0A02D8bE2324') 
        UNION
        SELECT
        "to" AS wallet,  -- Stake
        value AS value,
        CASE
            WHEN contract_address = '\x44017598f2AF1bD733F9D87b5017b4E7c1B28DDE' THEN 'stkATOM'
            WHEN contract_address = '\x45e007750Cc74B1D2b4DD7072230278d9602C499' THEN 'stkXPRT'
            WHEN contract_address = '\x2C5Bcad9Ade17428874855913Def0A02D8bE2324' THEN 'stkETH'
            ELSE 'Others' END AS vault
        FROM erc20."ERC20_evt_Transfer"
        WHERE contract_address IN ('\x44017598f2AF1bD733F9D87b5017b4E7c1B28DDE', '\x45e007750Cc74B1D2b4DD7072230278d9602C499',
        '\x2C5Bcad9Ade17428874855913Def0A02D8bE2324')
    ) c
    WHERE wallet NOT IN 
    ('\x0000000000000000000000000000000000000000',
    '\x0000000000000000000000000000000000000001',
    '\x000000000000000000000000000000000000dead')
    GROUP BY 1,2
    ORDER BY 2 DESC
) w
WHERE staked_balance != 0
ORDER BY 3 DESC;