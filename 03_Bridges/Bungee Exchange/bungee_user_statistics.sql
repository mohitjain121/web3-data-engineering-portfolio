/*
Description: Calculate total, new, and retained users based on transaction data.
*/

WITH 
    total_users AS (
        SELECT 
            COUNT(DISTINCT sender) AS total_users
        FROM 
            query_{{txns_table_query}}
        WHERE 
            sender IN (
                SELECT 
                    address 
                FROM 
                    query_{{wallets_query}}
            )
    ),
    new_users AS (
        SELECT 
            COUNT(DISTINCT sender) AS new_users
        FROM 
            query_{{txns_table_query}}
        WHERE 
            evt_block_time >= CAST('{{start_date}}' AS TIMESTAMP)
            AND sender IN (
                SELECT 
                    address 
                FROM 
                    query_{{wallets_query}}
            )
            AND sender NOT IN (
                SELECT 
                    DISTINCT sender
                FROM 
                    query_{{txns_table_query}}
                WHERE 
                    evt_block_time < CAST('{{start_date}}' AS TIMESTAMP)
            )
    ),
    retained_users AS (
        SELECT 
            COUNT(DISTINCT sender) AS retained_users
        FROM 
            query_{{txns_table_query}}
        WHERE 
            evt_block_time > CAST('{{end_date}}' AS TIMESTAMP)
            AND sender IN (
                SELECT 
                    address 
                FROM 
                    query_{{wallets_query}}
            )
    )

SELECT 
    total_users.total_users
    , new_users.new_users
    , 100.0 * CAST(new_users.new_users AS double) / total_users.total_users AS new_users_percentage
    , retained_users.retained_users
    , 100.0 * CAST(retained_users.retained_users AS double) / total_users.total_users AS retained_users_percentage
FROM 
    total_users
    , new_users
    , retained_users