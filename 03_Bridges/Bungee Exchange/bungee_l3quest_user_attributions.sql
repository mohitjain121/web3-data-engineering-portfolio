/*
Description: This query calculates various transaction and user metrics for different blockchains.
*/

SELECT
    blockchain,
    total_transactions,
    l3_quest_users_txns_all_time,
    100.0 * CAST(l3_quest_users_txns_all_time AS double) / total_transactions AS "txn_%_all_time",
    total_users_30_day,
    l3_quest_users_30_day,
    100.0 * CAST(l3_quest_users_30_day AS double) / total_users_30_day AS "txn_%_30_day",
    total_users,
    l3_quest_users,
    100.0 * CAST(l3_quest_users AS double) / total_users AS "user_%_all_time"
FROM
(
    SELECT
        blockchain,
        COUNT(evt_tx_hash) AS total_transactions,
        COUNT(
            CASE 
                WHEN sender IN (SELECT address FROM query_{{wallets_query}})
                THEN evt_tx_hash 
            END
        ) AS l3_quest_users_txns_all_time,
        COUNT(DISTINCT sender) AS total_users,
        COUNT(
            DISTINCT CASE 
                WHEN sender IN (SELECT address FROM query_{{wallets_query}})
                AND evt_block_time >= CAST('{{start_date}}' AS TIMESTAMP) 
                AND evt_block_time <= CAST('{{end_date}}' AS TIMESTAMP)
                THEN sender 
            END
        ) AS l3_quest_users,
        COUNT(
            CASE 
                WHEN evt_block_time >= CAST('{{start_date}}' AS TIMESTAMP) 
                AND evt_block_time <= CAST('{{end_date}}' AS TIMESTAMP) + INTERVAL '30' DAY 
                THEN evt_tx_hash 
            END
        ) AS total_users_30_day,
        COUNT(
            CASE 
                WHEN sender IN (SELECT address FROM query_{{wallets_query}}) 
                AND evt_block_time >= CAST('{{start_date}}' AS TIMESTAMP) 
                AND evt_block_time <= CAST('{{end_date}}' AS TIMESTAMP) + INTERVAL '30' DAY 
                THEN evt_tx_hash 
            END
        ) AS l3_quest_users_30_day
    FROM
        query_{{txns_table_query}}
    WHERE
        blockchain IN ('arbitrum', 'optimism', 'polygon')
    GROUP BY
        blockchain
) sub