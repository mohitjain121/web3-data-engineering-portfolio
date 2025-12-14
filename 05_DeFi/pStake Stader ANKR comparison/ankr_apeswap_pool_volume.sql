/* Description: Calculate daily WBNB and ABNBC prices and swapped amounts */
WITH 
  wbnb_price AS (
    SELECT 
      date_trunc('DAY', minute) AS datex,
      AVG(price) AS wbnb_price
    FROM 
      prices."usd"
    WHERE 
      symbol = 'WBNB' -- wbnb
    GROUP BY 1
  ),
  abnbc_price AS (
    SELECT 
      datex,
      abnbc_price
    FROM 
      dune_user_generated.abnbc_price
  )
SELECT 
  datex,
  bnb_swapped_in * wbnb_price + abnbc_swapped_in * abnbc_price
FROM (
  SELECT 
    date_trunc('DAY', evt_block_time) AS datex,
    abnbc_price,
    wbnb_price,
    SUM(CASE 
            WHEN "to" = '\x1C3BFdA8d788689ab2Fb935a9499c67e098A9E84' 
            AND contract_address = '\xbb4cdb9cbd36b01bd1cbaebf2de08d9173bc095c'
            THEN value / 1e18 END) AS bnb_swapped_in,
    SUM(CASE 
            WHEN "to" = '\x1C3BFdA8d788689ab2Fb935a9499c67e098A9E84' 
            AND contract_address = '\xe85afccdafbe7f2b096f268e31cce3da8da2990a'
            THEN value / 1e18 END) AS abnbc_swapped_in
  FROM 
    bep20."BEP20_evt_Transfer" s
    INNER JOIN wbnb_price p1 ON p1.datex = date_trunc('DAY', s.evt_block_time)
    INNER JOIN abnbc_price p2 ON p2.datex = date_trunc('DAY', s.evt_block_time)
  WHERE 
    evt_block_time > '2022-04-05'
  GROUP BY 1, 2, 3
) x
ORDER BY 1 DESC;