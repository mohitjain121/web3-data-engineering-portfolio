WITH 

supply AS 
(SELECT 
    SUM(value)/1e18 as total_supply  
FROM erc20."ERC20_evt_Transfer"
WHERE 
    contract_address = '\x4104b135DBC9609Fc1A9490E61369036497660c8'
    AND "from" = '\x0000000000000000000000000000000000000000'),


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

traded_volume AS 
(SELECT
    DATE_TRUNC('DAY', block_time) as datex,
    CASE WHEN token_a_address = '\x4104b135DBC9609Fc1A9490E61369036497660c8' THEN token_b_symbol 
    ELSE token_a_symbol END AS token_traded_against,
    SUM(usd_amount) AS sum_usd
FROM dex."trades"
WHERE 
    token_a_address = '\x4104b135DBC9609Fc1A9490E61369036497660c8' 
    OR token_b_address = '\x4104b135DBC9609Fc1A9490E61369036497660c8'
GROUP BY 1,2
ORDER BY 1 DESC),

transfers AS 
(SELECT 
    "from" AS address,
    evt_tx_hash AS tx_hash,
    (-1)*value AS amount,
    contract_address
FROM erc20."ERC20_evt_Transfer"
WHERE 
    contract_address =  '\x4104b135DBC9609Fc1A9490E61369036497660c8'
    AND "from" != '\x0000000000000000000000000000000000000000'

UNION ALL

SELECT 
    "to" AS address,
    evt_tx_hash AS tx_hash,
    value AS amount,
    contract_address
FROM erc20."ERC20_evt_Transfer"
where 
    contract_address = '\x4104b135DBC9609Fc1A9490E61369036497660c8'
    AND "to" != '\x0000000000000000000000000000000000000000'),

circ_supply AS 
(SELECT
    SUM(balance) AS circ_supply
FROM
(SELECT 
    address,
    SUM(amount)/1e18 as balance  
FROM transfers 
GROUP BY 1) p
WHERE "address" NOT in 
        ('\x16d96ba86512b4f8d10bd74b1061d9f576d9c55d', --Vesting Account
        '\xC5ca1EBF6e912E49A6a70Bb0385Ea065061a4F09', --Voting Escrow Accunt
        '\xdbbfc051d200438dd5847b093b22484b842de9e7', --Treasury
        '\x2aF9b355A578e8bF422bB7EbB5EE7434F24d5ef3', --Sushi Rewarder
        '\x1A3E8De7e155fd91B7B3726EE20498762756227f', --New rewarder mainnet
        '\x639D20F70bcc01A25355720EF6590Beab6e4a0E7', --Merkletree
        '\x6610c566B01ad2076CFdFf3cf68515aaE76a9035', --Old rewarder mainnet 
        '\x7b4396aac0FF6A948546F4A5200aB9592B28251C', --Polygon DAO Main Msig
        '\xAbae9C064bf1fd92Fcfc7052D23De7029C6bbD95', --Polygon Bounties Msig
        '\x150fb0cfa5bf3d4023ba198c725b6dcbc1577f21', --rewarder polygon
        '\x277A2C1F890D527434cA5eA1286019e083c5A8ee', --Cometh rewarder
        '\x8E4b31931aE58Fc0479BeE2FF5Cf9961832045eC', --Cometh staking contract 
        '\x9e9d9F1217D9efF596CBdFa044e19371d440E711', --Nested reserve
        '\x40ec5b33f54e0e8a33a975908c5ba1c14e5bbbdf' --Polygon Bridge
        )),

holders AS 
(SELECT 
    address,
    SUM(amount)/1e18 as holdings 
FROM transfers 
GROUP BY 1)

SELECT 
    *
FROM
(SELECT 
    price, 
    circ_supply,
    (price * total_supply) AS total_marketcap, 
    (price * circ_supply) AS current_marketcap, 
    SUM(sum_usd) AS traded_volume
FROM price, supply, circ_supply, traded_volume
GROUP BY 1,2,3,4) x 
CROSS JOIN
(SELECT
    SUM(holdings) AS supply,
    COUNT(DISTINCT(address)) as holders
FROM holders
WHERE holdings > 0) z
