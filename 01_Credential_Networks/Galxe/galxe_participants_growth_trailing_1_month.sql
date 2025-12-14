/*
Description: Calculates monthly user growth rate based on aggregated event participation data.
*/
WITH participant AS
(
SELECT
    CASE
        WHEN (evt_block_time > NOW() - INTERVAL '1 MONTH') THEN '2'
        ELSE '1'
    END AS datex,
    COUNT(DISTINCT _sender) AS num_users
FROM
    (
    SELECT DISTINCT
        _sender,
        evt_block_time
    FROM
        project_galaxy."SpaceStation_evt_EventClaimBatch"

    UNION

    SELECT DISTINCT
        _sender,
        evt_block_time
    FROM
        project_galaxy."SpaceStation_evt_EventClaim"

    UNION

    SELECT DISTINCT
        _sender,
        evt_block_time
    FROM
        project_galaxy."SpaceStation_evt_EventForge"
    ) AS x
WHERE
    evt_block_time > NOW() - INTERVAL '2 MONTHS'
GROUP BY
    1
)

SELECT
    datex,
    SUM(num_users) AS count_users,
    -- Calculate percentage growth rate using a window function for prior period comparison
    (
        (SUM(num_users) - LAG(SUM(num_users), 1) OVER (ORDER BY datex))
        / LAG(SUM(num_users), 1) OVER (ORDER BY datex)
    ) * 100 AS growth
FROM
    participant
GROUP BY
    1;