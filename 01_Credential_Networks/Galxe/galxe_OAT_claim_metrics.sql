/* 
Description: Calculates the total, unique, and per-user count of successful OAT mint claims.
*/
SELECT
    COUNT(account) AS "Total OAT Claims"
    ,COUNT(DISTINCT account) AS "Unique OAT Claims"
    ,CAST(COUNT(account) AS FLOAT) / CAST(COUNT(DISTINCT account) AS FLOAT) AS "OAT Claims Per User" -- Calculate ratio of total claims to unique users.
FROM
    project_galaxy."GalaxyOAT_call_mint"
WHERE
    call_success = TRUE