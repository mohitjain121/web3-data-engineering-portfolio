/* 
Description: Calculates market capitalization metrics (MCAP and FDV) based on hardcoded supply figures and current asset price.
*/
WITH supply AS
(
    SELECT
        *,
        ROUND(circulating_supply / TRY_CAST(total_supply AS REAL) * 100, 2) AS perc_of -- Calculate percentage of circulating supply against total supply
    FROM
    (
        SELECT
            343818550 AS circulating_supply,
            1000000000 AS total_supply
    ) AS x
),

fort_price AS
(
    SELECT
        price
    FROM
        prices.usd_latest
    WHERE
        symbol = 'FORT'
)

SELECT
    circulating_supply,
    total_supply,
    perc_of,
    price,
    CAST(circulating_supply AS DOUBLE) * price AS market_cap,
    CAST(total_supply AS DOUBLE) * price AS fully_diluted_market_cap
FROM
    supply,
    fort_price