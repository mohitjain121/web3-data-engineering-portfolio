/*
Description: Calculates the daily count of successful OAT claims from the Galaxy mint events.
*/
SELECT
    date_trunc('DAY', call_block_time) AS "Date"
,    COUNT(account) AS "OAT Claims Daily"
FROM
    project_galaxy."GalaxyOAT_call_mint"
WHERE
    call_success = TRUE
GROUP BY
    1
ORDER BY
    1 DESC