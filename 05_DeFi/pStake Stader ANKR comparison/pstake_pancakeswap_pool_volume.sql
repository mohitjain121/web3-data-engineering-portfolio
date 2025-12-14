/* Description: Calculate daily BNB and stkBNB swapped in/out on PancakeSwap */
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
  
  -- Get stkBNB price
  stkbnb_price AS (
    SELECT 
      datex,
      stkbnb_price
    FROM 
      dune_user_generated.stkbnb_price
  )
  
SELECT 
  datex,
  bnb_swapped_in * wbnb_price + stkbnb_swapped_in * stkbnb_price
FROM (
  SELECT 
    date_trunc('DAY', evt_block_time) AS datex,
    stkbnb_price,
    wbnb_price,
    SUM("amount0In" / 1e18) AS bnb_swapped_in,
    SUM("amount0Out" / 1e18) AS bnb_swapped_out,
    SUM("amount1In" / 1e18) AS stkbnb_swapped_in,
    SUM("amount1Out" / 1e18) AS stkbnb_swapped_out
  FROM 
    pancakeswap_v2."PancakePair_evt_Swap" s
    INNER JOIN wbnb_price p1 ON p1.datex = date_trunc('DAY', s.evt_block_time)
    INNER JOIN stkbnb_price p2 ON p2.datex = date_trunc('DAY', s.evt_block_time)
  WHERE 
    contract_address = '\xaa2527ff1893e0d40d4a454623d362b79e8bb7f1' 
  GROUP BY 1, 2, 3
) x
ORDER BY 1 DESC;