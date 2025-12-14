/* Description: Calculate daily token transfers in USD */
WITH
price AS 
-- Calculate daily average price
(SELECT
    minute::DATE AS datex,  -- Date of the minute
    AVG(price) AS price     -- Average price for the minute
FROM
    prices."usd"            -- Table containing price data
WHERE symbol = 'WBNB'       -- Filter by WBNB symbol
GROUP BY 1),               -- Group by date

transfers AS 
-- Calculate daily token transfers
(SELECT
	block_time::DATE AS datex,  -- Date of the block
	SUM(value/1e18) AS token_transfers  -- Sum of token transfers
FROM
	bsc."transactions"          -- Table containing transaction data
GROUP BY 1)                   -- Group by date

SELECT
    COALESCE(t.datex, p.datex) AS datex,  -- Date of the transfer (or price)
    token_transfers,                     -- Total token transfers
    price,                               -- Average price
    token_transfers * price AS usd_transfers  -- Total transfers in USD
FROM
    transfers t                         -- Transfers table
    LEFT JOIN price p ON p.datex = t.datex  -- Join price table on date