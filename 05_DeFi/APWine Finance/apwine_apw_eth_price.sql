SELECT
    DATE_TRUNC('DAY', hour) AS "Date",
    AVG(CASE
        WHEN symbol = 'APW' THEN median_price ELSE NULL END) AS "$APW",
    AVG(CASE   
        WHEN symbol = 'WETH' THEN median_price ELSE NULL END) AS "$ETH"
        -- ELSE NULL END
FROM 
-- prices."usd"
dex."view_token_prices" d JOIN
erc20."tokens" e ON d.contract_address = e.contract_address
WHERE 
    symbol IN ('APW', 'WETH')
    AND hour > CURRENT_DATE - '12 MONTHS'::INTERVAL
GROUP BY 1
ORDER BY 1 DESC

