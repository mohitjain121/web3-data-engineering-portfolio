WITH 

one_day_volume AS (
    SELECT 
        project AS "Project",                        
        SUM(usd_amount) as usd_volume                                                                             
    FROM dex."trades"                                                                          
    WHERE block_time > NOW() - '24 HOURS'::INTERVAL
    AND "token_a_address" ='\x4104b135DBC9609Fc1A9490E61369036497660c8'
    GROUP BY 1),
    
seven_day_volume AS
    (SELECT 
        project AS "Project",                        
        SUM(usd_amount) as usd_volume                                                                             
    FROM dex."trades"                                                                          
    WHERE block_time > NOW() - '7 DAYS'::INTERVAL
    AND "token_a_address" ='\x4104b135DBC9609Fc1A9490E61369036497660c8'
    GROUP BY 1), 
    
thirty_day_volume AS
    (SELECT 
        project AS "Project",                        
        SUM(usd_amount) as usd_volume                                                                             
    FROM dex."trades"                                                                          
    WHERE block_time > NOW() - '30 DAYS'::INTERVAL
    AND "token_a_address" ='\x4104b135DBC9609Fc1A9490E61369036497660c8'
    GROUP BY 1)

SELECT 
    ROW_NUMBER () OVER (ORDER BY SUM(thirty.usd_volume) DESC) AS "Rank",
    thirty."Project",
    SUM(thirty.usd_volume) AS "30 Days Volume",
    SUM(seven.usd_volume) AS "7 Days Volume",
    SUM(one.usd_volume) AS "24 Hours Volume"
FROM
    thirty_day_volume thirty
    LEFT JOIN seven_day_volume seven ON thirty."Project" = seven."Project"
    LEFT JOIN one_day_volume one ON thirty."Project" = one."Project"
-- WHERE 
    -- thirty.usd_volume IS NOT NULL 
    -- AND seven.usd_volume IS NOT NULL
GROUP BY 2
ORDER BY 1 ASC