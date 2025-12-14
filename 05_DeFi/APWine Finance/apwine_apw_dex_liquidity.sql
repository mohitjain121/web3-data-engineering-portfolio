WITH

price AS 
(SELECT
    date_trunc('DAY', hour) AS datex,
    symbol,
    median_price AS price
FROM 
dex."view_token_prices" d JOIN
erc20."tokens" e ON d.contract_address = e.contract_address
WHERE 
    symbol IN ('APW')
),

dex_liquidity AS 
(SELECT
    date_trunc('DAY', day) AS datex,
    pool_name,
    project,
    token_symbol,
    token_amount AS liquidity,
    token_usd_amount
FROM dex.liquidity
WHERE 
    pool_address IN 
        (
        '\x073d987513ca27ae5801f389c6ec5bd8c84909b2',
        '\x53162d78dca413d9e28cf62799d17a9e278b60e8',
        '\x2860b0dafa49adcf45d857eb5e6c353a9a4b6626',
        '\x33d7e8c1d4933518f291b5dfc375eb44a812cb2a'
        )
    AND token_amount > 0
-- GROUP BY 1,2,3,4
)


SELECT
    datex,
    pool_name,
    project,
    SUM(liquid$ity) AS total_liquidity
FROM
(SELECT
    d.datex,
    pool_name,
    project,
    token_symbol,
    CASE
        WHEN token_symbol = 'APW' THEN AVG(price)
        ELSE token_usd_amount/liquidity END AS pricex,
    liquidity AS tokens,
    CASE
        WHEN token_symbol = 'APW' THEN AVG(liquidity*price)
        ELSE token_usd_amount END AS liquid$ity 
FROM 
    dex_liquidity d
    LEFT JOIN price p ON d.datex = p.datex AND d.token_symbol = p.symbol
GROUP BY 1,2,3,4,token_usd_amount,liquidity
ORDER BY 1 DESC) x
GROUP BY 1,2,3
ORDER BY 1 DESC