/*
Description: This query calculates the number of bots per day, considering the stake and agent status.
*/

WITH 
agents_creation AS (
    SELECT 
        *
    FROM 
        forta_polygon.agentregistry_call_createagent
    WHERE 
        call_success = TRUE

    UNION ALL 

    SELECT 
        *
    FROM 
        forta_network_polygon.agentregistry_call_createagent
    WHERE 
        call_success = TRUE
),

agents_chainids AS (
    SELECT
        chains,
        agentid,
        owner
    FROM
        agents_creation
    CROSS JOIN UNNEST (chainids) AS _u (chains)
),

events AS (
    SELECT 
        date_trunc('day', call_block_time) AS day,
        agentid,
        call_block_number AS block_number,
        1 AS value

    FROM 
        forta_polygon.agentregistry_call_createagent
    WHERE 
        call_success = TRUE

    UNION ALL 

    SELECT 
        date_trunc('day', call_block_time) AS day,
        agentid,
        call_block_number AS block_number,
        1 AS value

    FROM 
        forta_network_polygon.agentregistry_call_createagent
    WHERE 
        call_success = TRUE

    UNION ALL 

    SELECT 
        date_trunc('day', evt_block_time) AS day,
        agentid,
        evt_block_number AS block_number,
        1 AS value

    FROM 
        forta_polygon.agentregistry_evt_agentenabled
    WHERE 
        enabled = TRUE

    UNION ALL 

    SELECT 
        date_trunc('day', evt_block_time) AS day,
        agentid,
        evt_block_number AS block_number,
        1 AS value

    FROM 
        forta_network_polygon.agentregistry_evt_agentenabled
    WHERE 
        enabled = TRUE

    UNION ALL 

    SELECT 
        date_trunc('day', call_block_time) AS day,
        agentid,
        call_block_number AS block_number,
        0 AS value

    FROM 
        forta_polygon.agentregistry_call_disableagent
    WHERE 
        call_success = TRUE

    UNION ALL 

    SELECT 
        date_trunc('day', call_block_time) AS day,
        agentid,
        call_block_number AS block_number,
        0 AS value

    FROM 
        forta_network_polygon.agentregistry_call_disableagent
    WHERE 
        call_success = TRUE
),

daily_latest_tmp AS (
    SELECT 
        day,
        agentid,
        value,
        ROW_NUMBER() OVER (PARTITION BY day, agentid ORDER BY block_number DESC) AS filter

    FROM 
        events
),

daily_latest AS (
    SELECT 
        *

    FROM 
        daily_latest_tmp
    WHERE 
        filter = 1
),

daily_latest_gap AS (
    SELECT 
        day,
        agentid,
        value,
        LEAD(DAY, 1, NOW()) OVER (PARTITION BY agentid ORDER BY day ASC) AS next_day

    FROM 
        daily_latest
),

time_seq AS (
    SELECT 
        SEQUENCE(
            CAST('2021-10-18' AS TIMESTAMP),
            DATE_TRUNC('DAY', CAST(NOW() AS TIMESTAMP)),
            INTERVAL '1' DAY
        ) AS time
),

days AS (
    SELECT 
        time.time AS day

    FROM 
        time_seq
    CROSS JOIN UNNEST(time) AS time(time)
),

daily_filled AS (
    SELECT 
        d.day,
        dg.agentid,
        dg.value

    FROM 
        daily_latest_gap dg
    INNER JOIN 
        days d
            ON dg.day <= d.day
            AND d.day < dg.next_day
),

staking_unstaking AS (
    SELECT 
        DATE_TRUNC('DAY', call_block_time) AS day,
        subject,
        SUM(stakevalue/1e18) AS stake

    FROM 
        forta_network_polygon.fortastaking_call_deposit f
    INNER JOIN 
        polygon.transactions p
            ON f.call_tx_hash = p.hash
            AND f.subjecttype = 1
    WHERE 
        p.block_time >= CAST('2022-03-08' AS TIMESTAMP)
        AND p.to = 0xd2863157539b1d11f39ce23fc4834b62082f6874
        AND p.hash != 0x4132d43661e04b69641f2d526d5e0086c280dfe9a454f8386017b1e15b0efaf9
        AND BYTEARRAY_SUBSTRING(p.data, 1, 4) = 0x2cb31144
        AND f.call_success = TRUE
    GROUP BY 
        1, 2

    UNION ALL 

    SELECT 
        DATE_TRUNC('DAY', call_block_time) AS day,
        subject,
        -1 * SUM(output_0/1e18) AS stake

    FROM 
        forta_network_polygon.fortastaking_call_withdraw f
    INNER JOIN 
        polygon.transactions p
            ON f.call_tx_hash = p.hash
            AND f.subjecttype = 1
    WHERE 
        p.block_time >= CAST('2022-03-08' AS TIMESTAMP)
        AND p.to = 0xd2863157539b1d11f39ce23fc4834b62082f6874
        AND BYTEARRAY_SUBSTRING(p.data, 1, 4) = 0x3f489914
        AND f.call_success = TRUE
    GROUP BY 
        1, 2
),

balances AS (
    SELECT 
        day,
        subject,
        SUM(stake) AS stake

    FROM 
        staking_unstaking
    GROUP BY 
        1, 2
),

rolling_balance AS (
    SELECT 
        day,
        subject,
        SUM(stake) OVER (PARTITION BY subject ORDER BY day ASC) AS stake_over_time,
        LEAD(DAY, 1, NOW()) OVER (PARTITION BY subject ORDER BY day ASC) AS next_day

    FROM 
        balances
),

time_seq_key AS (
    SELECT 
        SEQUENCE(
            CAST('2022-04-01' AS TIMESTAMP),
            DATE_TRUNC('DAY', CAST(NOW() AS TIMESTAMP)),
            INTERVAL '1' DAY
        ) AS time
),

days_key AS (
    SELECT 
        time.time AS day

    FROM 
        time_seq_key
    CROSS JOIN UNNEST(time) AS time(time)
),

daily_balances AS (
    SELECT 
        d.day,
        rb.subject,
        SUM(rb.stake_over_time) AS daily_stake

    FROM 
        rolling_balance rb
    INNER JOIN 
        days_key d
            ON rb.day <= d.day
            AND d.day < rb.next_day
    GROUP BY 
        1, 2
),

minimum_stake AS (
    SELECT 
        *

    FROM 
        daily_balances
    WHERE 
        daily_stake >= 100
),

stake_node_id AS (
    SELECT 
        ms.*,
        r.*

    FROM 
        minimum_stake ms
    LEFT JOIN 
        agents_chainids r
            ON ms.subject = r.agentid
)

SELECT 
    *

FROM 
(
    SELECT 
        df.day,
        COUNT(DISTINCT(s.owner)) AS n_of_bots

    FROM 
        daily_filled df
    INNER JOIN 
        stake_node_id s
            ON df.day = s.day
            AND df.agentid = s.subject
            AND df.value = 1
    GROUP BY 
        1
)
ORDER BY 
    1 DESC