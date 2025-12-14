/* Description: Calculate active and total wallets for yearn vaults in 2021 and 2022. */

WITH 
h2_21 AS 
(SELECT
    vault,
    COUNT(DISTINCT CASE WHEN wallet_balance > 0 THEN wallet ELSE NULL END) AS active_wallets_h2_21,
    COUNT(DISTINCT wallet) AS total_wallets_h2_21
FROM 
    (SELECT 
        wallet, 
        vault,
        SUM(value) as wallet_balance
    FROM
    (SELECT
        t.contract_address, 
        CONCAT(ytoken, ' ', tag) AS vault,
        t.from AS wallet,
        (-1)*value/10^(y.decimals) AS value
        FROM
        erc20.ERC20_evt_Transfer t
        INNER JOIN yearn.yearn_all_vaults y
        ON t.contract_address = y.contract_address
        WHERE evt_block_time <= '2021-12-31 23:59:59'
    UNION
        SELECT
        t.contract_address, 
        CONCAT(ytoken, ' ', tag) AS vault,
        t.to AS wallet,
        value/10^(y.decimals) AS value
        FROM
        erc20.ERC20_evt_Transfer t
        INNER JOIN yearn.yearn_all_vaults y
        ON t.contract_address = y.contract_address
        WHERE evt_block_time <= '2021-12-31 23:59:59') c
    GROUP BY 1,2
) a
WHERE wallet NOT IN 
('\x0000000000000000000000000000000000000000',
'\x0000000000000000000000000000000000000001',
'\x000000000000000000000000000000000000dead')
GROUP BY 1
), 

h1_22 AS 
(SELECT
    vault,
    COUNT(DISTINCT CASE WHEN wallet_balance > 0 THEN wallet ELSE NULL END) AS active_wallets_h1_22,
    COUNT(DISTINCT wallet) AS total_wallets_h1_22
FROM 
    (SELECT 
        wallet, 
        vault,
        SUM(value) as wallet_balance
    FROM
    (SELECT
        t.contract_address, 
        CONCAT(ytoken, ' ', tag) AS vault,
        t.from AS wallet,
        (-1)*value/10^(y.decimals) AS value
        FROM
        erc20.ERC20_evt_Transfer t
        INNER JOIN yearn.yearn_all_vaults y
        ON t.contract_address = y.contract_address
        WHERE evt_block_time <= '2022-06-30 23:59:59'
    UNION
        SELECT
        t.contract_address, 
        CONCAT(ytoken, ' ', tag) AS vault,
        t.to AS wallet,
        value/10^(y.decimals) AS value
        FROM
        erc20.ERC20_evt_Transfer t
        INNER JOIN yearn.yearn_all_vaults y
        ON t.contract_address = y.contract_address
        WHERE evt_block_time <= '2022-06-30 23:59:59') c
    GROUP BY 1,2
) a
WHERE wallet NOT IN 
('\x0000000000000000000000000000000000000000',
'\x0000000000000000000000000000000000000001',
'\x000000000000000000000000000000000000dead')
GROUP BY 1
)

SELECT
    COALESCE(a.vault, b.vault) AS vault,
    active_wallets_h2_21,
    active_wallets_h1_22,
    (active_wallets_h1_22 - active_wallets_h2_21) AS active_wallet_change,
    total_wallets_h2_21,
    total_wallets_h1_22,
    (total_wallets_h1_22 - total_wallets_h2_21) / total_wallets_h2_21::FLOAT AS total_wallets_growth
FROM
    h2_21 a
    FULL JOIN h1_22 b ON a.vault = b.vault
ORDER BY 6 DESC;