/* 
Description: Calculates the daily count of newly launched campaigns and their cumulative total over time.
*/
WITH campaign_first_event AS (
    -- Identify the minimum event block time (launch date) for each unique campaign ID (_cid) within each event table
    SELECT
        _cid,
        DATE_TRUNC('DAY', MIN(evt_block_time)) AS datex
    FROM
        project_galaxy."SpaceStation_evt_EventClaim"
    GROUP BY
        1

    UNION

    SELECT
        _cid,
        DATE_TRUNC('DAY', MIN(evt_block_time)) AS datex
    FROM
        project_galaxy."SpaceStation_evt_EventClaimBatch"
    GROUP BY
        1

    UNION

    SELECT
        _cid,
        DATE_TRUNC('DAY', MIN(evt_block_time)) AS datex
    FROM
        project_galaxy."SpaceStation_evt_EventForge"
    GROUP BY
        1
),

daily_campaign_launches AS (
    -- Count distinct campaigns launched per effective launch date
    SELECT
        datex AS "Date",
        COUNT(DISTINCT _cid) AS "Campaigns Launched"
    FROM
        campaign_first_event
    GROUP BY
        1
)

SELECT
    "Date",
    "Campaigns Launched",
    -- Calculate the running total of campaigns launched
    SUM("Campaigns Launched") OVER (
        ORDER BY
            "Date" ASC
    ) AS "Cumulative Campaigns"
FROM
    daily_campaign_launches
GROUP BY
    1,
    2
<ctrl63>