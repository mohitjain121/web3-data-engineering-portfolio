/* Description: Calculate weekly transaction metrics for a specific ERC20 contract. */

SELECT
    date_trunc('WEEK', evt_block_time) AS datex,
    SUM(
        CASE 
            WHEN 
                "from" = '\x0000000000000000000000000000000000000000' OR 
                "to" = '\x0000000000000000000000000000000000000000' 
                THEN 1
            ELSE 0 END
    ) AS "Total Transactions Weekly",
    SUM(
        CASE 
            WHEN "from" = '\x0000000000000000000000000000000000000000' THEN 1
            ELSE 0 END
    ) AS "Deposits Weekly",
    COUNT(DISTINCT 
        CASE 
            WHEN "from" = '\x0000000000000000000000000000000000000000' THEN "to"
            ELSE NULL END
    ) AS "Depositors Weekly",
    SUM(
        CASE 
            WHEN "to" = '\x0000000000000000000000000000000000000000' THEN 1
            ELSE 0 END
    ) AS "Withdrawals Weekly",
    COUNT(DISTINCT 
        CASE 
            WHEN "to" = '\x0000000000000000000000000000000000000000' THEN "from"
            ELSE NULL END
    ) AS "Withdrawers Weekly",
    SUM(
        CASE 
            WHEN "from" = '\x0000000000000000000000000000000000000000' THEN value/10^18
            ELSE 0 END
    ) AS "Deposit Amount Weekly",
    SUM(
        CASE 
            WHEN "to" = '\x0000000000000000000000000000000000000000' THEN value/10^18
            ELSE 0 END
    ) AS "Withdrawal Amount Weekly",
    SUM(
        CASE 
            WHEN "from" = '\x0000000000000000000000000000000000000000' THEN value/10^18
            WHEN "to" = '\x0000000000000000000000000000000000000000' THEN -value/10^18
            ELSE NULL END
    ) AS "Net Asset Change Weekly"
FROM 
    erc20."ERC20_evt_Transfer"
WHERE 
    contract_address = '\x2C5Bcad9Ade17428874855913Def0A02D8bE2324'
GROUP BY 1
ORDER BY 1 ASC;