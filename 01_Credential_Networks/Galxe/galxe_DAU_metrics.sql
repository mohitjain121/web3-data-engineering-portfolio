/*
Description: Calculates daily unique, new, and repeat campaign participants, along with the cumulative count of new participants over time.
*/
WITH event_activity AS (
    -- Combine all event claim activity logs
    SELECT
        evt_block_time
      , _sender
    FROM
        project_galaxy."SpaceStation_evt_EventClaim"

    UNION

    SELECT
        evt_block_time
      , _sender
    FROM
        project_galaxy."SpaceStation_evt_EventClaimBatch"

    UNION

    SELECT
        evt_block_time
      , _sender
    FROM
        project_galaxy."SpaceStation_evt_EventForge"
),

daily_unique_users AS (
    -- Subquery Z: Calculates the total unique users active on any given day
    SELECT
        date_trunc('DAY', evt_block_time) AS datex
      , COUNT(DISTINCT _sender) AS unique_users
    FROM
        event_activity
    GROUP BY
        1
),

first_activity AS (
    -- Subquery X: Finds the first observed date for every unique participant (_sender)
    SELECT
        MIN(date_trunc('DAY', evt_block_time)) AS datex
      , _sender AS unique_user_id
    FROM
        event_activity
    GROUP BY
        2 -- Grouped by _sender (unique_user_id)
),

daily_new_users AS (
    -- Subquery Y: Counts how many users had their first activity on that specific day
    SELECT
        datex
      , COUNT(unique_user_id) AS users_new
    FROM
        first_activity
    GROUP BY
        1
)

SELECT
    y.datex AS "Date"
  , z.unique_users AS "Total Campaign Participants Daily"
  , y.users_new AS "New Campaign Participants Daily"
  , (z.unique_users - y.users_new) AS "Repeat Campaign Participants Daily"
  , SUM(y.users_new) OVER (ORDER BY y.datex ASC) AS "Cumulative Campaign Participants"
FROM
    daily_new_users AS y
LEFT JOIN
    daily_unique_users AS z
    ON z.datex = y.datex
ORDER BY
    y.datex ASC