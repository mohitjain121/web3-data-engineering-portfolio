/* Description: Calculate the distribution of tokens among top wallet holders for each vault. */

WITH wallets AS 
(
    SELECT 
        CONCAT('<a href="https://etherscan.io/address/0', SUBSTRING(wallet::text, 2), '" target="_blank" >', wallet, '</a>') AS wallet, 
        vault,
        SUM(value)/10^(CASE 
            WHEN vault = 'stkETH' THEN 18 ELSE 6 END) as staked_balance
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
    ORDER BY 2 DESC),

wallet_rank AS 
(
    SELECT
        wallet,
        vault,
        staked_balance,
        SUM(staked_balance) OVER (PARTITION BY vault ORDER BY staked_balance DESC) AS cum_wallet_holdings,
        DENSE_RANK() OVER (PARTITION BY vault ORDER BY staked_balance DESC) AS wallet_rank
    FROM wallets
    WHERE staked_balance > 0.00001
    GROUP BY 1,2,3),

vault_rank AS 
(
    SELECT 
        vault,
        SUM(staked_balance) as cir_supply,
        COUNT(DISTINCT wallet) as no_holders
    FROM
    wallet_rank
    GROUP BY 1
)

SELECT
    w.vault,
    v.cir_supply as total_tokens,
    SUM(CASE WHEN w.wallet_rank::float/nullif(v.no_holders::float,0) <= 0.01 THEN w.staked_balance::float ELSE NULL END)/v.cir_supply::float as "% vault held by top 1%",
    SUM(CASE WHEN w.wallet_rank::float/nullif(v.no_holders::float,0) <= 0.05 THEN w.staked_balance::float ELSE NULL END)/v.cir_supply::float as "% vault held by top 5%",
    SUM(CASE WHEN w.wallet_rank::float/nullif(v.no_holders::float,0) <= 0.10 THEN w.staked_balance::float ELSE NULL END)/v.cir_supply::float as "% vault held by top 10%"
    -- SUM(CASE WHEN w.wallet_rank = ROUND(v.no_holders/2,2) THEN w.staked_balance ELSE NULL END ) as "Median token balance"
FROM
    wallet_rank w
    JOIN vault_rank v on v.vault = w.vault
GROUP BY 1,2