/*
Description: Calculate daily participation rate of wallets in transactions on specific blockchains.
*/
SELECT 
    date(evt_block_time) AS day,
    count(sender) AS participation_rate
FROM 
(
    SELECT 
        max(evt_block_time) AS evt_block_time,
        sender
    FROM 
        query_{{txns_table_query}}
    WHERE 
        evt_block_time >= cast('{{start_date}}' AS timestamp)
        AND evt_block_time <= cast('{{end_date}}' AS timestamp)
        AND blockchain IN ('arbitrum', 'optimism', 'polygon')
        AND sender IN 
        (
            SELECT 
                address 
            FROM 
                query_{{wallets_query}}
        )
    GROUP BY 
        sender
)
sub
GROUP BY 
    day
ORDER BY 
    day ASC