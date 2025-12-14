/* Description: Calculate daily WBNB and BNBX prices and swapped values */
WITH 
  -- Calculate daily WBNB price
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
  
  -- Get BNBX price
  bnbx_price AS (
    SELECT 
      datex,
      bnbx_price
    FROM 
      dune_user_generated.bnbx_price
  )
  
SELECT 
  datex,
  bnb_swapped_in * wbnb_price + bnbx_swapped_in * bnbx_price
FROM (
  SELECT 
    date_trunc('DAY', evt_block_time) AS datex,
    bnbx_price,
    wbnb_price,
    SUM(
      CASE 
        WHEN "to" = '\xb88f211ec9ecfc2931ae1de53ea28da76b9ed37a' 
        AND contract_address = '\xbb4cdb9cbd36b01bd1cbaebf2de08d9173bc095c'
        THEN value / 1e18 
      END) AS bnb_swapped_in,
    SUM(
      CASE 
        WHEN "to" = '\xb88f211ec9ecfc2931ae1de53ea28da76b9ed37a' 
        AND contract_address = '\x1bdd3Cf7F79cfB8EdbB955f20ad99211551BA275'
        THEN value / 1e18 
      END) AS bnbx_swapped_in
  FROM 
    bep20."BEP20_evt_Transfer" s
    INNER JOIN wbnb_price p1 ON p1.datex = date_trunc('DAY', s.evt_block_time)
    INNER JOIN bnbx_price p2 ON p2.datex = date_trunc('DAY', s.evt_block_time)
  WHERE 
    evt_block_time > '2022-08-13'
  GROUP BY 1, 2, 3
) x
ORDER BY 1 DESC;