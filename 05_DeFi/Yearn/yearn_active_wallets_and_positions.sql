/* Description: Calculate active wallet and position growth between two time periods. */

WITH 
h2_21 AS 
(
    SELECT
        COUNT(DISTINCT CASE WHEN wallet_balance > 0 THEN wallet ELSE NULL END) AS active_wallets_h2_21,
        COUNT(DISTINCT wallet) AS total_wallets_h2_21,
        SUM(CASE WHEN wallet_balance > 0 THEN 1 ELSE 0 END) AS active_positions_h2_21,
        COUNT(wallet) AS total_positions_h2_21
    FROM 
        (
            SELECT 
                wallet, 
                tag, 
                SUM(value) AS wallet_balance, 
                symbol
            FROM
            (
                SELECT
                    t."contract_address", 
                    y.symbol,
                    y.tag,
                    t."from" AS wallet,
                    (-1)*value/10^(y.decimals) AS value
                FROM
                    erc20."ERC20_evt_Transfer" t
                    INNER JOIN yearn."yearn_all_vaults" y
                    ON t."contract_address" = y.contract_address
                WHERE evt_block_time <= '2021-12-31 23:59:59'
            UNION
                SELECT
                    t."contract_address", 
                    y.symbol,
                    y.tag,
                    t."to" AS wallet,
                    value/10^(y.decimals) AS value
                FROM
                    erc20."ERC20_evt_Transfer" t
                    INNER JOIN yearn."yearn_all_vaults" y
                    ON t."contract_address" = y.contract_address
                WHERE evt_block_time <= '2021-12-31 23:59:59'
            ) c
            GROUP BY 1, 2, 4
        ) a
    WHERE wallet NOT IN 
        ('\x0000000000000000000000000000000000000000',
         '\x0000000000000000000000000000000000000001',
         '\x000000000000000000000000000000000000dead')
), 

h1_22 AS 
(
    SELECT
        COUNT(DISTINCT CASE WHEN wallet_balance > 0 THEN wallet ELSE NULL END) AS active_wallets_h1_22,
        COUNT(DISTINCT wallet) AS total_wallets_h1_22,
        SUM(CASE WHEN wallet_balance > 0 THEN 1 ELSE 0 END) AS active_positions_h1_22,
        COUNT(wallet) AS total_positions_h1_22
    FROM 
        (
            SELECT 
                wallet, 
                tag, 
                SUM(value) AS wallet_balance, 
                symbol
            FROM
            (
                SELECT
                    t."contract_address", 
                    y.symbol,
                    y.tag,
                    t."from" AS wallet,
                    (-1)*value/10^(y.decimals) AS value
                FROM
                    erc20."ERC20_evt_Transfer" t
                    INNER JOIN yearn."yearn_all_vaults" y
                    ON t."contract_address" = y.contract_address
                WHERE evt_block_time <= '2022-06-30 23:59:59'
            UNION
                SELECT
                    t."contract_address", 
                    y.symbol,
                    y.tag,
                    t."to" AS wallet,
                    value/10^(y.decimals) AS value
                FROM
                    erc20."ERC20_evt_Transfer" t
                    INNER JOIN yearn."yearn_all_vaults" y
                    ON t."contract_address" = y.contract_address
                WHERE evt_block_time <= '2022-06-30 23:59:59'
            ) c
            GROUP BY 1, 2, 4
        ) a
    WHERE wallet NOT IN 
        ('\x0000000000000000000000000000000000000000',
         '\x0000000000000000000000000000000000000001',
         '\x000000000000000000000000000000000000dead')
)

SELECT
    *,
    (active_wallets_h1_22 - active_wallets_h2_21) * 100.0 / active_wallets_h2_21 AS active_wallet_growth,
    (active_positions_h1_22 - active_positions_h2_21) * 100.0 / active_positions_h2_21 AS active_positions_growth
FROM
    h2_21, h1_22