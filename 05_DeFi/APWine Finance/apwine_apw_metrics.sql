WITH 

transfers AS 
(SELECT
    evt_block_time,
    (-1)*value/1e18 AS amount
FROM erc20."ERC20_evt_Transfer"
WHERE 
    "from" =  '\xC5ca1EBF6e912E49A6a70Bb0385Ea065061a4F09' --Voting Escrow Account

UNION ALL

SELECT
    evt_block_time,
    value/1e18 AS amount
FROM erc20."ERC20_evt_Transfer"
where 
    "to" = '\xC5ca1EBF6e912E49A6a70Bb0385Ea065061a4F09' --Voting Escrow Account
    )
    
SELECT
    evt_block_time,
    SUM(amount) AS tokens_daily,
    SUM(SUM(amount)) OVER (ORDER BY t.evt_block_time) AS total_tokens
FROM 
    transfers t
GROUP BY t.evt_block_time
ORDER BY 1 DESC
