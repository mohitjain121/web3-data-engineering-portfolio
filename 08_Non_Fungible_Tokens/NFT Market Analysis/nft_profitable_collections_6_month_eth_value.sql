/* Description: Calculate profit share of NFT collections based on floor price and volume. */

WITH 
  -- Calculate daily average price of WETH
  eth_prices AS (
    SELECT 
      DATE_TRUNC('DAY', minute) AS week,
      AVG(price) AS price
    FROM 
      prices.usd
    WHERE 
      symbol = 'WETH'
      AND minute > now() - interval '6 MONTHS'
    GROUP BY 
      1
  ),

  -- Extract NFT trades data
  t AS (
    SELECT 
      DATE_TRUNC('DAY', block_time) AS Week,
      nft_contract_address AS "OPENSEA",
      SUM(original_amount) AS "Volume ETH", 
      percentile_cont(.1) within GROUP (ORDER BY original_amount) AS "Floor Price"
    FROM 
      nft.trades n
    WHERE 
      (block_time > now() - interval  '6 MONTHS') 
      AND number_of_items = 1 
      AND original_currency in ('ETH','WETH')  
      AND nft_contract_address NOT IN (
        '\x13225f3c304c47a6781e7f710a30c36cdee9e982',
        '\xbc578ecca2115dac0c93c08674edc0c7d01fe09c',
        '\xa5D37c0364b9E6D96EE37E03964E7aD2b33a93F4',
        '\xc36cf0cfcb5d905b8b513860db0cfe63f6cf9f5c', 
        '\x4e1f41613c9084fdb9e34e11fae9412427480e56', 
        '\x7bd29408f11d2bfc23c34f18275bbf23bb716bc7', 
        '\xce25e60a89f200b1fa40f6c313047ffe386992c3', 
        '\xfb3765e0e7ac73e736566af913fa58c3cfd686b7',
        '\x495f947276749ce646f68ac8c248420045cb7b5e',
        '\xc99f70bfd82fb7c8f8191fdfbfb735606b15e5c5',
        '\xb932a70a57673d89f4acffbe830e8ed7f75fb9e0', 
        '\x3b3ee1931dc30c1957379fac9aba94d1c48a5405'
      )
    GROUP BY 
      1, 2
  ),

  -- Calculate ATH floor price for each collection
  max_floor AS (
    SELECT 
      tt."OPENSEA" AS "OpenSea",
      tt.week AS "Week",
      tt."Floor Price" AS "ATH Floor Price (ETH)",
      AVG(tt."Floor Price" * ep.price) AS "ATH Floor Price (USD)" 
    FROM (
      SELECT 
        *,
        -- FIRST_VALUE(t."Floor Price") OVER (PARTITION BY t."OPENSEA" ORDER BY CASE WHEN t."Floor Price" IS NOT NULL THEN 0 ELSE 1 END ASC, Week ASC) AS "ATH Floor Price"
        MIN(t.Week) OVER (PARTITION BY t."OPENSEA") AS min_week
      FROM 
        t
    ) tt 
    JOIN 
      eth_prices ep ON tt.week = ep.week 
    -- WHERE tt."Floor Price" = tt."ATH Floor Price"
    WHERE 
      min_week = tt.week
    GROUP BY 
      1, 2, 3
  ),

  -- Calculate current floor price for each collection
  current_floor AS (
    SELECT 
      tt."OPENSEA" AS "OpenSea",
      tt.week AS "Week",
      tt."Volume ETH" AS "Weekly Volume ETH",
      tt."Floor Price" AS "Current Floor Price (ETH)"
      -- ,
      -- AVG(tt."Floor Price" * ep.price) AS "Current Floor Price (USD)"
    FROM (
      SELECT 
        *,
        MAX(t.Week) OVER (PARTITION BY t."OPENSEA") AS max_week
      FROM 
        t
    ) tt 
    JOIN 
      eth_prices ep ON tt.week = ep.week
    WHERE 
      max_week = tt.week
    GROUP BY 
      1, 2, 3, 4
  ),

  -- Calculate profit and loss for each collection
  pnl AS (
    SELECT 
      -- c."Week" AS "Week",
      c."OpenSea" AS "Collection",
      -- c."Week" - m."Week" AS "Days since ATH",
      c."Current Floor Price (ETH)",
      "ATH Floor Price (ETH)",
      -- (c."Current Floor Price (ETH)" - m."ATH Floor Price (ETH)") / m."ATH Floor Price (ETH)" * 100 AS "% From ATH (ETH)",
      (c."Current Floor Price (ETH)" - m."ATH Floor Price (ETH)") / m."ATH Floor Price (ETH)"::FLOAT AS profit,
      -- ROUND(((c."Current Floor Price (USD)" - m."ATH Floor Price (USD)") / m."ATH Floor Price (USD)" * 100)::DECIMAL, 2) AS "% From ATH (USD)",
      SUM("Volume ETH") AS "Volume ETH"
    FROM 
      t 
    LEFT JOIN 
      current_floor c ON c."OpenSea" = t."OPENSEA"
    LEFT JOIN 
      max_floor m ON c."OpenSea" = m."OpenSea"
    WHERE 
      m."ATH Floor Price (ETH)" != 0
    GROUP BY 
      1, 2, 3, 4
    HAVING 
      SUM("Volume ETH") >= 3000
  )

SELECT 
  count_profit,
  count_total,
  count_profit / count_total::FLOAT AS profit_share
FROM (
  SELECT 
    COUNT(DISTINCT CASE WHEN profit > 0 THEN "Collection" END) AS count_profit,
    COUNT(DISTINCT "Collection") AS count_total
  FROM 
    pnl
) x