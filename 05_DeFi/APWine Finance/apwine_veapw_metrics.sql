WITH 

transfers AS 
(SELECT
    "to" AS address,
    (-1)*value/1e18 AS amount
FROM erc20."ERC20_evt_Transfer"
WHERE 
    "from" =  '\xC5ca1EBF6e912E49A6a70Bb0385Ea065061a4F09' --Voting Escrow Account

UNION ALL

SELECT
    "from" AS address,
    value/1e18 AS amount
FROM erc20."ERC20_evt_Transfer"
where 
    "to" = '\xC5ca1EBF6e912E49A6a70Bb0385Ea065061a4F09' --Voting Escrow Account
    ),

price AS 
(SELECT
    median_price AS price
FROM 
dex."view_token_prices" d JOIN
erc20."tokens" e ON d.contract_address = e.contract_address
WHERE 
    symbol = 'APW'
ORDER BY hour DESC
LIMIT 1),

holders AS 
(SELECT
    address,
    SUM(amount) as holdings 
FROM transfers 
GROUP BY 1)


SELECT
    price,
    SUM(holdings) AS total_token,
    SUM(holdings*price) AS token_value,
    COUNT(DISTINCT address) AS holders,
    SUM(holdings)/COUNT(DISTINCT address) AS "AVG veAPW Per Holder"
FROM 
    holders,price
WHERE holdings > 0
GROUP BY 1