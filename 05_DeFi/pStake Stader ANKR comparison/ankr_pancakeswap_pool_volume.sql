/* Description: Calculate daily WBNB and ABNBC price swaps on PancakeSwap */
WITH 
  -- Get daily WBNB price
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
  
  -- Get daily ABNBC price
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
    SUM("amount0In" / 1e18) AS bnb_swapped_in,
    SUM("amount0Out" / 1e18) AS bnb_swapped_out,
    SUM("amount1In" / 1e18) AS abnbc_swapped_in,
    SUM("amount1Out" / 1e18) AS abnbc_swapped_out
  FROM 
    pancakeswap_v2."PancakePair_evt_Swap" s
    INNER JOIN wbnb_price p1 ON p1.datex = date_trunc('DAY', s.evt_block_time)
    INNER JOIN abnbc_price p2 ON p2.datex = date_trunc('DAY', s.evt_block_time)
  WHERE 
    contract_address = '\x272c2CF847A49215A3A1D4bFf8760E503A06f880' 
  GROUP BY 1, 2, 3
) x
ORDER BY 1 DESC;