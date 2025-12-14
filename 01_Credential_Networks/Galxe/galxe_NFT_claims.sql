/* 
Description: Calculates the total number of claims aggregated across different campaign event types.
*/
WITH raw_event_metrics AS (
    -- Campaign claims calculation from three different event tables
    
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
        -- Counts total NFTs claimed using array length function (PostgreSQL/Redshift syntax)
        SUM(array_length("_nftIDArr", 1)) AS "Number of Claims", 
        COUNT(DISTINCT _sender) AS "Unique Campaign Participants"
    FROM
        project_galaxy."SpaceStation_evt_EventClaimBatch"
    GROUP BY
        1
),

intermediate_results AS (
    -- Preserves the intermediate grouping and ordering logic from the original structure
    SELECT
        "Campaign ID",
        "Number of Claims",
        "Unique Campaign Participants"
    FROM
        raw_event_metrics
    GROUP BY
        1,
        2,
        3
    ORDER BY
        2 DESC
)

SELECT
    SUM("Number of Claims")
FROM
    intermediate_results;