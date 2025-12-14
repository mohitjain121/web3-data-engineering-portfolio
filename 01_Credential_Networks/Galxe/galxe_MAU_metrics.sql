/*
Description: Calculates monthly metrics for campaign participants, differentiating between new and repeat users based on their first activity date.
*/
WITH base_events AS (
    SELECT
        evt_block_time,
        _sender
    FROM
        project_galaxy."SpaceStation_evt_EventClaim"
    UNION
    SELECT
        evt_block_time,
        _sender
    FROM
        project_galaxy."SpaceStation_evt_EventClaimBatch"
    UNION
    SELECT
        evt_block_time,
        _sender
    FROM
        project_galaxy."SpaceStation_evt_EventForge"
),

-- Determines the first month of activity (cohort month) for every unique user (Original X logic)
user_first_month AS (
    SELECT
        _sender AS participant_id,
        MIN(date_trunc('MONTH', evt_block_time)) AS first_month_cohort
    FROM
        base_events
    GROUP BY
        1
),

-- Counts users whose first activity month is the current month (Original Y logic)
new_participants AS (
    SELECT
        first_month_cohort AS datex,
        COUNT(participant_id) AS users_new
    FROM
        user_first_month
    GROUP BY
        1
),

-- Counts total unique users active in any given month (Original Z logic)
total_participants AS (
    SELECT
        date_trunc('MONTH', evt_block_time) AS datex,
        COUNT(DISTINCT _sender) AS unique_users
    FROM
        base_events
    GROUP BY
        1
)

SELECT
    y.datex AS "Month",
    z.unique_users AS "Total Campaign Participants Monthly",
    y.users_new AS "New Campaign Participants Monthly",
    -- Calculate repeat users by subtracting new users from total unique users.
    (z.unique_users - y.users_new) AS "Repeat Campaign Participants Montly"
FROM
    new_participants y
LEFT JOIN
    total_participants z
        ON z.datex = y.datex
ORDER BY
    y.datex DESC