/* Description: Calculate weekly transaction metrics for a specific BEP20 contract. */

SELECT
    date_trunc('DAY', evt_block_time) AS datex,
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
FROM bep20."BEP20_evt_Transfer"
WHERE contract_address IN (
    '\xc2E9d07F66A89c44062459A47a0D2Dc038E4fb16' --BNB
)
GROUP BY 1
ORDER BY 1 ASC;