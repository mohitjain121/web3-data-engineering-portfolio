/*
Description: Calculate total, new, and retained users across different blockchains.
*/

WITH 
    total_users_list AS (
        SELECT 
            DISTINCT 
            blockchain,
            sender,
            CONCAT(
                CAST(blockchain AS varchar), 
                CAST(sender AS varchar)
            ) AS concatted
        FROM 
            query_{{txns_table_query}}
        WHERE 
            evt_block_time >= CAST('{{start_date}}' AS TIMESTAMP)
            AND evt_block_time <= CAST('{{end_date}}' AS TIMESTAMP)
            AND sender IN (
                SELECT 
                    address 
                FROM 
                    query_{{wallets_query}}
            )
            AND blockchain IN (
                'arbitrum', 
                'optimism', 
                'polygon'
            )
    ),
    total_users AS (
        SELECT 
            DISTINCT 
            blockchain,
            COUNT(DISTINCT sender) AS total_users
        FROM 
            total_users_list
        GROUP BY 
            1
    ),
    new_users AS (
        SELECT 
            DISTINCT 
            blockchain,
            COUNT(DISTINCT sender) AS new_users
        FROM 
            query_{{txns_table_query}}
        WHERE 
            evt_block_time >= CAST('{{start_date}}' AS TIMESTAMP)
            AND sender IN (
                SELECT 
                    address 
                FROM 
                    query_2640016
            )
            AND sender NOT IN (
                SELECT 
                    DISTINCT 
                    sender
                FROM 
                    query_{{txns_table_query}}
                WHERE 
                    evt_block_time < CAST('{{start_date}}' AS TIMESTAMP)
            )
        GROUP BY 
            1
    ),
    retained_users AS (
        SELECT 
            DISTINCT 
            blockchain,
            COUNT(DISTINCT sender) AS retained_users
        FROM 
            query_{{txns_table_query}}
        WHERE 
            evt_block_time > CAST('{{end_date}}' AS TIMESTAMP)
            AND CONCAT(
                CAST(blockchain AS varchar), 
                CAST(sender AS varchar)
            ) IN (
                SELECT 
                    concatted 
                FROM 
                    total_users_list
            )
        GROUP BY 
            1
    )
SELECT 
    t.blockchain,
    t.total_users,
    n.new_users,
    100.0 * CAST(n.new_users AS double) / t.total_users AS new_users_percentage,
    r.retained_users,
    100.0 * CAST(r.retained_users AS double) / t.total_users AS retained_users_percentage
FROM 
    total_users t
JOIN 
    new_users n ON t.blockchain = n.blockchain
JOIN 
    retained_users r ON t.blockchain = r.blockchain