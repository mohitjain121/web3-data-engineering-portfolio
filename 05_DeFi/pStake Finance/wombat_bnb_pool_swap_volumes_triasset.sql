/* Description: Calculate cumulative volumes for WBNB, ABNBC, stkBNB, and bnbX tokens. */

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
),

stkbnb_price AS (
  SELECT 
    datex,
    stkbnb_price
  FROM 
    dune_user_generated.stkbnb_price
),

bnbx_price AS (
  SELECT 
    datex,
    bnbx_price
  FROM 
    dune_user_generated.bnbx_price
),

prices AS (
  SELECT 
    COALESCE(a.datex, b.datex, c.datex, d.datex) AS datex,
    abnbc_price,
    bnbx_price,
    stkbnb_price,
    wbnb_price
  FROM 
    abnbc_price a
    FULL JOIN bnbx_price b ON a.datex = b.datex
    FULL JOIN stkbnb_price c ON c.datex = a.datex
    FULL JOIN wbnb_price d ON d.datex = a.datex
)

SELECT 
  datex,
  total_volume,
  SUM(total_volume) OVER (ORDER BY datex ASC) AS cumulative_total_volume,
  abnbc_volume,
  SUM(abnbc_volume) OVER (ORDER BY datex ASC) AS cumulative_abnbc_volume,
  stkbnb_volume,
  SUM(stkbnb_volume) OVER (ORDER BY datex ASC) AS cumulative_stkbnb_volume,
  bnbx_volume,
  SUM(bnbx_volume) OVER (ORDER BY datex ASC) AS cumulative_bnbx_volume
FROM (
  SELECT 
    date_trunc('DAY', evt_block_time) AS datex,
    SUM(
      CASE 
        WHEN "toToken" = '\xe85afccdafbe7f2b096f268e31cce3da8da2990a' THEN "toAmount"*abnbc_price/1e18
      END) AS abnbc_volume,
    SUM(
      CASE 
        WHEN "toToken" = '\xc2e9d07f66a89c44062459a47a0d2dc038e4fb16' THEN "toAmount"*stkbnb_price/1e18
      END) AS stkbnb_volume,
    SUM(
      CASE 
        WHEN "toToken" = '\x1bdd3cf7f79cfb8edbb955f20ad99211551ba275' THEN "toAmount"*bnbx_price/1e18
      END) AS bnbx_volume,
    SUM(
      CASE 
        WHEN "toToken" = '\xe85afccdafbe7f2b096f268e31cce3da8da2990a' THEN "toAmount"*abnbc_price/1e18
        WHEN "toToken" = '\xc2e9d07f66a89c44062459a47a0d2dc038e4fb16' THEN "toAmount"*stkbnb_price/1e18
        WHEN "toToken" = '\xbb4cdb9cbd36b01bd1cbaebf2de08d9173bc095c' THEN "toAmount"*wbnb_price/1e18
        WHEN "toToken" = '\x1bdd3cf7f79cfb8edbb955f20ad99211551ba275' THEN "toAmount"*bnbx_price/1e18
      END) AS total_volume
  FROM 
    wombat."DynamicPool_evt_Swap" i
    LEFT JOIN prices p ON date_trunc('DAY', i.evt_block_time) = p.datex
  GROUP BY 1
)
ORDER BY 1 DESC;