/* Description: Calculate daily vault metrics and total value locked */
SELECT 
    *,
    SUM("Net Asset Change") OVER (PARTITION BY vault ORDER BY datex ASC) AS "Vault Total Value Locked"
FROM (
    SELECT 
        date_trunc('DAY', evt_block_time) AS datex,
        CONCAT(y.ytoken, ' ', y.tag) AS vault,
        SUM(CASE 
                WHEN 
                    "from" = '\x0000000000000000000000000000000000000000' OR 
                    "to" = '\x0000000000000000000000000000000000000000' 
                    THEN 1
                ELSE NULL END) AS "Total Transactions",
        SUM(CASE 
                WHEN "from" = '\x0000000000000000000000000000000000000000' THEN 1
                ELSE NULL END) AS "Deposits Daily",
        COUNT(DISTINCT CASE 
                WHEN "from" = '\x0000000000000000000000000000000000000000' THEN "to"
                ELSE NULL END) AS "Depositors Daily",
        SUM(CASE
                WHEN "to" = '\x0000000000000000000000000000000000000000' THEN 1
                ELSE NULL END) AS "Withdrawals Daily",
        COUNT(DISTINCT CASE 
                WHEN "to" = '\x0000000000000000000000000000000000000000' THEN "from"
                ELSE NULL END) AS "Withdrawers Daily",
        SUM(CASE 
                WHEN "from" = '\x0000000000000000000000000000000000000000' THEN value/10^(decimals)
                ELSE 0 END) AS "Deposit Amount",
        SUM(CASE
                WHEN "to" = '\x0000000000000000000000000000000000000000' THEN value/10^(decimals)
                ELSE 0 END) AS "Withdrawal Amount",
        SUM(CASE 
                WHEN "from" = '\x0000000000000000000000000000000000000000' THEN value/10^(decimals) 
                WHEN "to" = '\x0000000000000000000000000000000000000000' THEN -value/10^(decimals) 
                ELSE NULL END) AS "Net Asset Change"
    FROM 
        erc20."ERC20_evt_Transfer" t
        -- yearn.transactions t 
        INNER JOIN yearn."yearn_all_vaults" y ON t.contract_address = y.contract_address 
        -- LEFT JOIN yearn."view_yearn_harvests" h ON t.evt_tx_hash = h.evt_tx_hash
    -- WHERE evt_block_time > NOW() - INTERVAL '6 MONTHS'
        -- AND CONCAT(y.ytoken, ' ', y.tag) NOT IN ('Yearn KRW ib', 'Yearn JPY ib')
    GROUP BY 1,2
    ORDER BY 1 ASC
) v
ORDER BY 1 DESC;