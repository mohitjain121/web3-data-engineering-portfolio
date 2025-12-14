/* Description: Calculate stkbnb pool TVL and token metrics */
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
  
  price AS (
    SELECT 
      COALESCE(a.datex, b.datex) AS datex,
      wbnb_price + stkbnb_price AS lp_token_price
    FROM 
      dune_user_generated.stkbnb_price a
      FULL JOIN wbnb_price b ON a.datex = b.datex
  ),
  
  tokens AS (
    SELECT 
      datex,
      SUM(lp_tokens) OVER (ORDER BY datex ASC) AS lp_tokens
    FROM (
      SELECT 
        date_trunc('DAY', evt_block_time) AS datex,
        SUM(
          CASE 
            WHEN "from" = '\x0000000000000000000000000000000000000000' THEN value/1e18
            WHEN "to" = '\x0000000000000000000000000000000000000000' THEN (-1)*value/1e18
          END
        ) AS lp_tokens
      FROM 
        bep20."BEP20_evt_Transfer"
      WHERE 
        contract_address = '\xd23ef71883a98c55Eb7ED67ED61fABF554aDEd21'
      GROUP BY 1
    ) x
  )

SELECT 
  t.datex, 
  AVG(lp_token_price) AS lp_token_price,
  AVG(lp_tokens) AS lp_tokens,
  AVG(lp_token_price * lp_tokens) AS stkbnb_pool_tvl
FROM 
  tokens t
  LEFT JOIN price p ON p.datex = t.datex
GROUP BY 1
ORDER BY 1 DESC;