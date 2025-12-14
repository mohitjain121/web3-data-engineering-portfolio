/*
Description: Calculates the average number of unique participants per campaign event across various claim types.
*/
WITH camp_participant AS (
    SELECT
        COUNT("Participant") AS "TP"
    FROM
        (
            SELECT
                "Participant",
                "Campaigns",
                "Number of Claims"
            FROM
                (
                    SELECT
                        _sender AS "Participant",
                        COUNT(_cid) AS "Number of Claims",
                        COUNT(DISTINCT _cid) AS "Campaigns"
                    FROM
                        project_galaxy."SpaceStation_evt_EventClaim"
                    GROUP BY
                        1
                    UNION
                    SELECT
                        _sender AS "Participant",
                        COUNT(_cid) AS "Number of Claims",
                        COUNT(DISTINCT _cid) AS "Campaigns"
                    FROM
                        project_galaxy."SpaceStation_evt_EventForge"
                    GROUP BY
                        1
                    UNION
                    SELECT
                        _sender AS "Participant",
                        COUNT(_cid) AS "Number of Claims",
                        COUNT(DISTINCT _cid) AS "Campaigns"
                    FROM
                        project_galaxy."SpaceStation_evt_EventClaimBatch"
                    GROUP BY
                        1
                ) AS x
            GROUP BY
                1, 2, 3
            ORDER BY
                2 DESC
        ) AS y
),

no_camp AS (
    SELECT
        COUNT(DISTINCT _cid) AS "Number of Campaigns"
    FROM
        (
            SELECT DISTINCT
                _cid
            FROM
                project_galaxy."SpaceStation_evt_EventClaimBatch"
            UNION
            SELECT DISTINCT
                _cid
            FROM
                project_galaxy."SpaceStation_evt_EventClaim"
            UNION
            SELECT DISTINCT
                _cid
            FROM
                project_galaxy."SpaceStation_evt_EventForge"
        ) AS x
)

SELECT
    CAST("TP" AS FLOAT) / CAST("Number of Campaigns" AS FLOAT) AS "AVG Participant Per Campaign"
FROM
    camp_participant,
    no_camp
<ctrl63>