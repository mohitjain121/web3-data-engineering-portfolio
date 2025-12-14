/* Description: Weekly user engagement metrics */
SELECT 
    y.datex AS "week", 
    EXTRACT('WEEK' FROM y.datex) AS "week_number", 
    z.unique_users AS "unique_users_weekly", 
    y.users_new AS "new_users_weekly", 
    (z.unique_users - y.users_new) AS "repeat_users_weekly" 
FROM (
    SELECT 
        datex, 
        COUNT(unique_users) AS users_new 
    FROM (
        SELECT 
            MIN(date_trunc('WEEK', evt_block_time)) AS datex, 
            "wallet" AS unique_users
        FROM 
            idex_v3."Exchange_v3_1_evt_Deposited"     
        GROUP BY 2 
        ORDER BY 2
    ) x
    GROUP BY 1
) y
LEFT JOIN (
    SELECT 
        date_trunc('WEEK', evt_block_time) AS datex, 
        COUNT(DISTINCT "wallet") AS unique_users
    FROM 
        idex_v3."Exchange_v3_1_evt_Deposited"
    GROUP BY 
        datex 
    ORDER BY 
        datex
) z ON z.datex = y.datex
ORDER BY 
    y.datex DESC;