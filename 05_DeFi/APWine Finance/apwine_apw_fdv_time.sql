WITH 

supply AS 
(SELECT
    GENERATE_SERIES('2010-01-01'::TIMESTAMP, date_trunc('DAY', NOW()), '1 DAY') AS datex,
    SUM(value/1e18) OVER () as total_supply  
FROM erc20."ERC20_evt_Transfer"
WHERE 
    contract_address = '\x4104b135DBC9609Fc1A9490E61369036497660c8'
    AND "from" = '\x0000000000000000000000000000000000000000'),


price AS 
(SELECT
    date_trunc('DAY', hour) AS datex,
    median_price AS price
FROM 
dex."view_token_prices" d JOIN
erc20."tokens" e ON d.contract_address = e.contract_address
WHERE 
    symbol = 'APW')

SELECT
    p.datex,
    price,
    (price * total_supply) AS marketcap 
FROM 
    price p
    LEFT JOIN supply s ON s.datex = p.datex
ORDER BY 1 DESC
