WITH across_dexes AS 
(SELECT
    tx_hash,
    block_time,
    CASE
        WHEN token_b_address = '\x4104b135DBC9609Fc1A9490E61369036497660c8' THEN 'Sell'
        ELSE 'Buy'
    END AS action,
    CASE
        WHEN token_b_address = '\x4104b135DBC9609Fc1A9490E61369036497660c8' THEN usd_amount/token_b_amount
        ELSE usd_amount/token_a_amount
    END AS price,
    token_b_amount,
    token_b_symbol,
    token_a_amount,
    token_a_symbol
FROM dex.trades
WHERE token_a_address = '\x4104b135DBC9609Fc1A9490E61369036497660c8'
OR token_b_address = '\x4104b135DBC9609Fc1A9490E61369036497660c8'
ORDER BY 2 DESC),

buy_vol AS 
(SELECT
    DATE_TRUNC('WEEK', block_time) AS datex,
    action,
    AVG(price) AS price,
    SUM(token_a_amount) AS buy_amt 
FROM across_dexes
WHERE action = 'Buy'
GROUP BY 1,2),

sell_vol AS 
(SELECT
    DATE_TRUNC('WEEK', block_time) AS datex,
    action,
    AVG(price) AS price,
    SUM(token_b_amount) AS sell_amt 
FROM across_dexes
WHERE action = 'Sell'
GROUP BY 1,2),

weekly_vol AS 
(SELECT 
    b.datex AS datex,
    b.buy_amt*b.price AS weekly_buy,
    s.sell_amt*s.price AS weekly_sell
FROM buy_vol b LEFT JOIN sell_vol s ON s.datex = b.datex
WHERE b.datex > CURRENT_DATE - '1 YEAR'::INTERVAL
ORDER BY b.datex DESC)

SELECT
    datex,
    weekly_buy,
    weekly_sell,
    weekly_buy + weekly_sell AS weekly_traded_tokens,
    SUM(weekly_buy) OVER (ORDER BY datex) AS cumulative_buy,
    SUM(weekly_sell) OVER (ORDER BY datex) AS cumulative_sell
FROM weekly_vol