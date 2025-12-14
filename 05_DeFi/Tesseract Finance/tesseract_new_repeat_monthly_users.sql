/* Description: Monthly user statistics for specific token recipients */

SELECT 
    y.datex AS "month", 
    EXTRACT('MONTH' FROM y.datex) AS "month_number", 
    unique_users AS "users_monthly", 
    users_new AS "new_users_monthly", 
    (unique_users - users_new) AS "repeat_users_monthly"
FROM (
    SELECT 
        datex, 
        COUNT(unique_users) AS users_new 
    FROM (
        SELECT 
            MIN(date_trunc('MONTH', evt_block_time)) AS datex, 
            "from" AS unique_users
        FROM 
            erc20."ERC20_evt_Transfer"
        WHERE 
            ("to" = '\xBC85571Cd19303FF45A37bAF9bf446C48B1F7671'  -- Tricrypto
            OR "to" = '\xE11678341625cD88Bb25544e39B2c62CeDcC83f1'  -- MATIC
            OR "to" = '\x57bDbb788d0F39aEAbe66774436c19196653C3F2'  -- USDC
            OR "to" = '\x4c8C6379b7cd039C892ab179846CD30a1A52b125'  -- DAI
            OR "to" = '\x3d44F03a04b08863cc8825384f834dfb97466b9B'  -- WETH
            OR "to" = '\x6962785c731e812073948a1f5E181cf83274D7c6'  -- WBTC
            )
        GROUP BY 2
        ORDER BY 2
    ) x
    GROUP BY 1
) y
LEFT JOIN (
    SELECT 
        date_trunc('MONTH', evt_block_time) AS datex, 
        COUNT(DISTINCT "from") AS unique_users
    FROM 
        erc20."ERC20_evt_Transfer"
    WHERE 
        ("to" = '\xBC85571Cd19303FF45A37bAF9bf446C48B1F7671'  -- Tricrypto
        OR "to" = '\xE11678341625cD88Bb25544e39B2c62CeDcC83f1'  -- MATIC
        OR "to" = '\x57bDbb788d0F39aEAbe66774436c19196653C3F2'  -- USDC
        OR "to" = '\x4c8C6379b7cd039C892ab179846CD30a1A52b125'  -- DAI
        OR "to" = '\x3d44F03a04b08863cc8825384f834dfb97466b9B'  -- WETH
        OR "to" = '\x6962785c731e812073948a1f5E181cf83274D7c6'  -- WBTC
        )
    GROUP BY datex
    ORDER BY datex
) z ON z.datex = y.datex
ORDER BY y.datex DESC;