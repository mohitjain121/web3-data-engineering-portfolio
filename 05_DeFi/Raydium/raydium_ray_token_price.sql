/* Description: Retrieve hourly token prices for a specific contract address. */

SELECT 
    hour, 
    -- Calculate median price
    median_price AS price
FROM 
    dex."view_token_prices"
WHERE 
    contract_address = '\x5245C0249e5EEB2A0838266800471Fd32Adb1089' 
    AND median_price < 100
GROUP BY 
    hour, 
    median_price
ORDER BY 
    hour ASC