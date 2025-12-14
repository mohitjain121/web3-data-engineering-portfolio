/*
Description: Calculate daily stake balances and allocations for Forta Network Polygon.
*/

WITH 
    staking_unstaking AS (
        SELECT 
            date_trunc('day', call_block_time) AS day,
            'deposits' AS type_,
            SUM(stakeValue/1e18) AS stake
        FROM 
            forta_network_polygon.FortaStaking_call_deposit f
        INNER JOIN 
            polygon.transactions p
                ON f.call_tx_hash = p.hash
        WHERE 
            p.block_time >= CAST('2022-03-08' AS timestamp)
            AND p.to = 0xd2863157539b1D11F39ce23fC4834B62082F6874
            AND p.hash != 0x4132d43661e04b69641f2d526d5e0086c280dfe9a454f8386017b1e15b0efaf9
            AND bytearray_substring(p.data,1,4) = 0x2cb31144
            AND f.call_success = TRUE
        GROUP BY 
            1, 
            2

        UNION ALL 

        SELECT 
            date_trunc('day', call_block_time) AS day,
            'withdrawals' AS type_,
            SUM(output_0/1e18) AS stake
        FROM 
            forta_network_polygon.FortaStaking_call_withdraw f
        INNER JOIN 
            polygon.transactions p
                ON f.call_tx_hash = p.hash
        WHERE 
            p.block_time >= CAST('2022-03-08' AS timestamp)
            AND p.to = 0xd2863157539b1D11F39ce23fC4834B62082F6874
            AND bytearray_substring(p.data,1,4) = 0x3f489914
            AND f.call_success = TRUE
        GROUP BY 
            1, 
            2
    ), 

    summary AS (
        SELECT 
            day,
            SUM(CASE 
                WHEN type_ = 'withdrawals' THEN stake 
                ELSE 0 
                END) AS withdrawals,
            SUM(CASE 
                WHEN type_ = 'deposits' THEN stake 
                ELSE 0 
                END) AS deposits
        FROM 
            staking_unstaking
        GROUP BY 
            1
    ), 

    summary_2 AS (
        SELECT 
            day,
            SUM(withdrawals) OVER (ORDER BY day ASC) AS withdrawals_cum,
            SUM(deposits) OVER (ORDER BY day ASC) AS deposits_cum
        FROM 
            summary
    ),

    daily_balance AS 
    (SELECT 
        day,
        deposits_cum - withdrawals_cum AS daily_balance
    FROM 
        summary_2),

    -- list of dates to backfill
    date_table AS (
        SELECT 
            date_col
        FROM 
            UNNEST(sequence(date '2023-02-22', current_date, INTERVAL '1' DAY)) t (date_col)
    ),

    -- list of pools to backfill
    pool_table AS (
        SELECT 
            DISTINCT subject AS pool_id
        FROM 
            forta_network_polygon.StakeAllocator_evt_AllocatedStake
    ),

    -- backfill table dates and pools
    cross_table AS 
    (SELECT 
        date_col, 
        pool_id 
    FROM 
        date_table 
    CROSS JOIN 
        pool_table),

    -- table containing del/own stake for pools on a daily basis
    orig_table AS
    (SELECT
        day,
        pool_id,
        MAX(CASE WHEN subjectType = 2 THEN TRY_CAST(total_allocated AS INTEGER) END) AS own_stake,
        MAX(CASE WHEN subjectType = 3 THEN TRY_CAST(total_allocated AS INTEGER) END) AS del_stake
    FROM (
        SELECT
            DATE_TRUNC('day', evt_block_time) AS day,
            subject AS pool_id,
            subjectType,
            totalAllocated/1e18 AS total_allocated
        FROM 
            forta_network_polygon.StakeAllocator_evt_AllocatedStake
    ) AS x
    GROUP BY
        1,
        2
    )
    
SELECT
    w.day,
    total_own_stake,
    total_del_stake,
    total_allocated_stake,
    daily_balance - total_allocated_stake AS total_unallocated_stake,
    daily_balance AS total_stake
FROM
    (SELECT
        day,
        total_own_stake,
        total_del_stake,
        total_own_stake + total_del_stake AS total_allocated_stake
    FROM
        (SELECT
            day,
            SUM(own_stake) AS total_own_stake,
            SUM(del_stake) AS total_del_stake
        FROM
            -- join and backfill
            (SELECT 
                ct.date_col AS day
                , CASE WHEN ct.pool_id IS NULL 
                THEN LAST_VALUE(ct.pool_id) IGNORE NULLS OVER (PARTITION BY ct.pool_id ORDER BY ct.date_col ASC)
                ELSE ct.pool_id END AS pool_id
                , CASE WHEN own_stake IS NULL 
                THEN LAST_VALUE(own_stake) IGNORE NULLS OVER (PARTITION BY ct.pool_id ORDER BY date_col ASC)
                ELSE own_stake END AS own_stake
                , CASE WHEN del_stake IS NULL 
                THEN LAST_VALUE(del_stake) IGNORE NULLS OVER (PARTITION BY ct.pool_id ORDER BY date_col ASC)
                ELSE del_stake END AS del_stake
            FROM 
                cross_table ct
            LEFT JOIN 
                orig_table ot
            ON 
                ot.day = ct.date_col AND ot.pool_id = ct.pool_id
            ) x 
        GROUP BY 
            1
        ) z
    ) w 
LEFT JOIN 
    daily_balance b 
ON 
    w.day = b.day
ORDER BY 
    1 DESC