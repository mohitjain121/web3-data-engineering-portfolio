-- Description: Getting transactions from polygon DB having contract addresses of Tesserect LPs
SELECT 
    CASE 
        WHEN x.contract = '\xBC85571Cd19303FF45A37bAF9bf446C48B1F7671' THEN 'Tricrypto'
        WHEN x.contract = '\xE11678341625cD88Bb25544e39B2c62CeDcC83f1' THEN 'WMATIC'
        WHEN x.contract = '\x57bDbb788d0F39aEAbe66774436c19196653C3F2' THEN 'USDC'
        WHEN x.contract = '\x4c8C6379b7cd039C892ab179846CD30a1A52b125' THEN 'DAI'
        WHEN x.contract = '\x3d44F03a04b08863cc8825384f834dfb97466b9B' THEN 'WETH'
        WHEN x.contract = '\x6962785c731e812073948a1f5E181cf83274D7c6' THEN 'WBTC'
        ELSE 'OTHER'
    END AS asset_type,
    "Unique Depositors",
    "No. of Deposits",
    "Unique Withdrawers",
    "No. of Withdraws"
FROM (
    SELECT 
        "to" AS contract,
        COUNT(DISTINCT "from") AS "Unique Depositors",
        COUNT("from") AS "No. of Deposits"
    FROM 
        erc20."ERC20_evt_Transfer"
    WHERE 
        ("to" = '\xBC85571Cd19303FF45A37bAF9bf446C48B1F7671'
        OR "to" = '\xE11678341625cD88Bb25544e39B2c62CeDcC83f1'
        OR "to" = '\x57bDbb788d0F39aEAbe66774436c19196653C3F2'
        OR "to" = '\x4c8C6379b7cd039C892ab179846CD30a1A52b125'
        OR "to" = '\x3d44F03a04b08863cc8825384f834dfb97466b9B'
        OR "to" = '\x6962785c731e812073948a1f5E181cf83274D7c6')
    GROUP BY 
        "to"
) x
LEFT JOIN (
    SELECT 
        "from" AS contract,
        COUNT(DISTINCT "to") AS "Unique Withdrawers",
        COUNT("to") AS "No. of Withdraws"
    FROM 
        erc20."ERC20_evt_Transfer"
    WHERE 
        ("from" = '\xBC85571Cd19303FF45A37bAF9bf446C48B1F7671'
        OR "from" = '\xE11678341625cD88Bb25544e39B2c62CeDcC83f1'
        OR "from" = '\x57bDbb788d0F39aEAbe66774436c19196653C3F2'
        OR "from" = '\x4c8C6379b7cd039C892ab179846CD30a1A52b125'
        OR "from" = '\x3d44F03a04b08863cc8825384f834dfb97466b9B'
        OR "from" = '\x6962785c731e812073948a1f5E181cf83274D7c6')
    GROUP BY 
        "from"
) y ON x.contract = y.contract
GROUP BY 
    1, 2, 3, 4, 5
ORDER BY 
    2 DESC