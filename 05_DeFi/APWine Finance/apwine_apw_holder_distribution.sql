WITH 

transfers AS 
(SELECT 
    "from" AS address,
    evt_tx_hash AS tx_hash,
    (-1)*value AS amount,
    contract_address
FROM erc20."ERC20_evt_Transfer"
WHERE contract_address =  '\x4104b135DBC9609Fc1A9490E61369036497660c8'

UNION ALL

SELECT 
    "to" AS address,
    evt_tx_hash AS tx_hash,
    value AS amount,
    contract_address
FROM erc20."ERC20_evt_Transfer"
where contract_address = '\x4104b135DBC9609Fc1A9490E61369036497660c8'),

price AS 
(SELECT
    median_price AS price
FROM 
dex."view_token_prices" d JOIN
erc20."tokens" e ON d.contract_address = e.contract_address
WHERE 
    symbol = 'APW'
ORDER BY hour DESC
LIMIT 1)

SELECT 
    address,
    holdings,
    holdings*price AS "$Value Held",
    (holdings/SUM(holdings) OVER ()) AS "% Held"
FROM
(SELECT 
    CONCAT('<a href="https://etherscan.io/address/0', SUBSTRING("address"::text, 2), '" target="_blank" >', "address", '</a>') AS address,
    SUM(amount)/1e18 as holdings
FROM transfers
GROUP BY 1) x, price
WHERE holdings > 0
GROUP BY 1,2,3 ORDER BY 2 DESC