/* Description: Calculate daily active users and transactions, along with cumulative totals. */

SELECT
    datex,
    dau,
    SUM(dau) OVER (ORDER BY datex) AS cum_dau,
    daily_txns,
    SUM(daily_txns) OVER (ORDER BY datex) AS cum_daily_txns
FROM (
    SELECT 
        block_date AS datex, 
        COUNT(DISTINCT account_keys[0]) AS dau, 
        COUNT(id) AS daily_txns
    FROM 
        solana.transactions
    WHERE 
        array_contains(account_keys, 'FarmqiPv5eAj3j1GMdMCMUGXqPUvmquZtMy86QH6rzhG')
        AND success == true
        AND block_time >= '2022-07-01'
    GROUP BY 
        1
)
x