/*
Description: Calculates the total unique user count who interacted with SpaceStation claim or forge events in the last month.
*/
SELECT
    COUNT(DISTINCT _sender) AS "Number of Users"
FROM
    (
    SELECT DISTINCT
        _sender
    FROM
        project_galaxy."SpaceStation_evt_EventClaimBatch"
    WHERE
        evt_block_time > NOW() - INTERVAL '1 MONTH'

    UNION

    SELECT DISTINCT
        _sender
    FROM
        project_galaxy."SpaceStation_evt_EventClaim"
    WHERE
        evt_block_time > NOW() - INTERVAL '1 MONTH'

    UNION

    SELECT DISTINCT
        _sender
    FROM
        project_galaxy."SpaceStation_evt_EventForge"
    WHERE
        evt_block_time > NOW() - INTERVAL '1 MONTH'
    ) AS x