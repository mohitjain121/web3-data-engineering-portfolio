/*
Description: Calculate the number of nodes with minimum stake on each day.
*/

WITH 
    staking_unstaking AS (
        SELECT 
            date_trunc('day', call_block_time) AS day,
            subject,
            SUM(stakeValue / 1e18) AS stake
        FROM 
            forta_network_polygon.FortaStaking_call_deposit f
        INNER JOIN 
            polygon.transactions p
                ON f.call_tx_hash = p.hash
        WHERE 
            p.block_time >= CAST('2022-03-08' AS timestamp)
            AND p.to = 0xd2863157539b1D11F39ce23fC4834B62082F6874
            AND p.hash != 0x4132d43661e04b69641f2d526d5e0086c280dfe9a454f8386017b1e15b0efaf9
            AND bytearray_substring(p.data, 1, 4) = 0x2cb31144
            AND f.call_success = TRUE
        GROUP BY 
            1, 2

        UNION ALL 

        SELECT 
            date_trunc('day', call_block_time) AS day,
            subject,
            -1 * SUM(output_0 / 1e18) AS stake
        FROM 
            forta_network_polygon.FortaStaking_call_withdraw f
        INNER JOIN 
            polygon.transactions p
                ON f.call_tx_hash = p.hash
        WHERE 
            p.block_time >= CAST('2022-03-08' AS timestamp)
            AND p."to" = 0xd2863157539b1D11F39ce23fC4834B62082F6874
            AND bytearray_substring(p.data, 1, 4) = 0x3f489914
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
            LEAD(day, 1, NOW()) OVER (PARTITION BY subject ORDER BY day ASC) AS next_day
        FROM 
            balances
    ),

    time_seq AS (
        SELECT 
            sequence(
                CAST('2022-03-08' AS timestamp),
                date_trunc('day', CAST(NOW() AS timestamp)),
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

    daily_balances AS (
        SELECT 
            d.day, 
            CAST(rb.subject AS VARBINARY) AS subject, 
            SUM(rb.stake_over_time) AS daily_stake
        FROM 
            rolling_balance rb
        INNER JOIN 
            days d
                ON rb.day <= d.day
                AND d.day < rb.next_day
        GROUP BY 
            1, 2
    ), 

    minimum_stake AS (
        SELECT 
            *, 
            CASE 
                WHEN daily_stake >= 2500 AND day < CAST('2022-09-30' AS timestamp) THEN 'Yes'
                WHEN daily_stake >= 500 AND day >= CAST('2022-09-30' AS timestamp) THEN 'Yes'
                ELSE 'No'
            END AS minimum_stake
        FROM 
            daily_balances
    ), 

    register AS (
        SELECT 
            t.tokenID, 
            r.owner,
            r.chainId,
            r.call_tx_hash, 
            r.call_block_time,
            r.call_block_number
        FROM 
            forta_polygon.ScannerRegistry_call_register r
        LEFT JOIN
            forta_polygon.ScannerRegistry_evt_Transfer t
                ON r.call_tx_hash = t.evt_tx_hash
        WHERE 
            r.call_success = TRUE
    ), 

    stake_node_id AS (
        SELECT 
            ms.*,
            r.*
        FROM 
            minimum_stake ms
        LEFT JOIN 
            register r
                ON ms.subject = CAST(r.tokenID AS VARBINARY)
        WHERE 
            ms.minimum_stake = 'Yes'
    )

SELECT 
    COUNT(*) AS num_nodes,
    day
FROM 
    stake_node_id
GROUP BY 
    2
ORDER BY 
    2 DESC