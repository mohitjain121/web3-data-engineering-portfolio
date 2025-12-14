/* Description: Calculate supply, withdraw, and net deployments amounts */
SELECT
    transaction_type,
    SUM(CASE 
            WHEN amount > 0 THEN amount ELSE 0 END) AS "supply_amount",
    SUM(CASE 
            WHEN amount < 0 THEN amount ELSE 0 END) AS "withdraw_amount",
    SUM(amount) AS "net_deployments"
FROM iearn_v2."view_iearn_v2_deployments"
GROUP BY 1