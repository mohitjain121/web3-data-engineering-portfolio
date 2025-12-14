/*
Description: Aggregates claim and forge event participation metrics across multiple event types.
*/
SELECT
    "Campaign ID",
    "Number of Claims",
    "Unique Campaign Participants"
FROM
    (
        SELECT
            _cid AS "Campaign ID",
            COUNT(_sender) AS "Number of Claims",
            COUNT(DISTINCT _sender) AS "Unique Campaign Participants"
        FROM
            project_galaxy."SpaceStation_evt_EventClaim"
        GROUP BY
            1

        UNION

        SELECT
            _cid AS "Campaign ID",
            COUNT(_sender) AS "Number of Claims",
            COUNT(DISTINCT _sender) AS "Unique Campaign Participants"
        FROM
            project_galaxy."SpaceStation_evt_EventForge"
        GROUP BY
            1

        UNION

        SELECT
            _cid AS "Campaign ID",
            SUM(array_length("_nftIDArr", 1)) AS "Number of Claims", -- Calculates total number of claimed NFTs from the array length
            COUNT(DISTINCT _sender) AS "Unique Campaign Participants"
        FROM
            project_galaxy."SpaceStation_evt_EventClaimBatch"
        GROUP BY
            1
    ) AS x
GROUP BY
    1,
    2,
    3
ORDER BY
    2 DESC