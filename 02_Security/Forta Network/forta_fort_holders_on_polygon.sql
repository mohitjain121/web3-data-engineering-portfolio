/*
Description: Calculate the number of holders of a specific ERC20 token on the Polygon network over time.
*/

WITH 
    balances AS (
        SELECT 
            date_trunc('day', evt_block_time) AS day,
            -1 * SUM(ROUND(value/1e18, 4)) AS balance,
            "from" AS address
        FROM 
            erc20_polygon.evt_Transfer
        WHERE 
            evt_block_time >= CAST('2022-03-01' AS timestamp)
            AND contract_address = 0x9ff62d1FC52A907B6DCbA8077c2DDCA6E6a9d3e1
        GROUP BY 
            1, 
            3

        UNION ALL 

        SELECT 
            date_trunc('day', evt_block_time) AS day,
            SUM(ROUND(value/1e18, 4)) AS balance,
            "to" AS address
        FROM 
            erc20_polygon.evt_Transfer
        WHERE 
            evt_block_time >= CAST('2022-03-01' AS timestamp)
            AND contract_address = 0x9ff62d1FC52A907B6DCbA8077c2DDCA6E6a9d3e1
        GROUP BY 
            1, 
            3
    ),
    
    sum_balance AS (
        SELECT 
            day,
            SUM(balance) AS balance,
            address
        FROM 
            balances
        GROUP BY 
            1, 
            3
    ),
    
    balances_gap AS (
        SELECT 
            day,
            address,
            SUM(balance) OVER (PARTITION BY address ORDER BY day ASC) AS balance_over_time,
            LEAD(day, 1, NOW()) OVER (PARTITION BY address ORDER BY day ASC) AS next_day
        FROM 
            sum_balance
    ),
    
    time_seq AS (
        SELECT 
            sequence(
                CAST('2022-03-01' AS timestamp),
                date_trunc('day', CAST(NOW() AS timestamp)),
                INTERVAL '1' DAY
            ) AS time
    ),
    
    time_series AS (
        SELECT 
            time.time AS day
        FROM 
            time_seq
        CROSS JOIN UNNEST(time) AS time(time)
    ),
    
    daily_balances AS (
        SELECT 
            t.day,
            bg.address,
            SUM(bg.balance_over_time) AS daily_balance
        FROM 
            balances_gap bg
        INNER JOIN 
            time_series t
                ON bg.day <= t.day
                AND t.day < bg.next_day
        GROUP BY 
            1, 
            2
    ),
    
    num_holders AS (
        SELECT 
            day,
            COUNT(address) AS num_holders
        FROM 
            daily_balances
        WHERE 
            daily_balance > 0.001
        GROUP BY 
            1
    )

SELECT 
    *
FROM 
    num_holders
ORDER BY 
    1 DESC