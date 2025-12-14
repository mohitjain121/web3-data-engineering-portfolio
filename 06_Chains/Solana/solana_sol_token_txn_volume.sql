/* Description: Calculate SOL token transfers in USD */
WITH 
price AS 
-- Calculate average price of SOL per day
(SELECT
    minute::DATE AS datex,
    AVG(price) AS price
FROM
    prices.usd
WHERE symbol = 'SOL'
GROUP BY 1),
    
transfers AS 
-- Calculate total SOL token transfers per day
(SELECT
	block_date::DATE AS datex,
	SUM(ABS(token_balance_change)) AS token_transfers
FROM solana.account_activity
  WHERE token_mint_address = 'So11111111111111111111111111111111111111112'
GROUP BY 1)

-- Join transfers and price data on date
SELECT
    COALESCE(t.datex, p.datex) AS datex,
    t.token_transfers,
    p.price,
    t.token_transfers * p.price AS usd_transfers
FROM
    transfers t
    LEFT JOIN price p ON p.datex = t.datex