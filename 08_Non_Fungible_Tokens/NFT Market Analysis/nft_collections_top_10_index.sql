/* Description: Calculate the weekly median of top 10 NFT prices for specific contracts. */

WITH 
  t1 AS (
    SELECT 
      nft_contract_address,
      date_trunc('WEEK', block_time) AS day,
      percentile_cont(.1) WITHIN GROUP (
        ORDER BY 
          original_amount
      ) AS top_10_nft_median
    FROM 
      nft.trades
    WHERE 
      nft_token_id IS NOT NULL
      AND original_currency IN ('ETH', 'WETH')
      AND date_trunc('DAY', block_time) > date_trunc('DAY', NOW()) - INTERVAL '6 MONTHS'
      AND date_trunc('DAY', block_time) < date_trunc('DAY', NOW())
      AND nft_contract_address IN (
        '\xBC4CA0EdA7647A8aB7C2061c2E118A18a936f13D', --BAYC
        '\xb47e3cd837dDF8e4c57F05d70Ab865de6e193BBB', --CryptoPunks
        '\x60E4d786628Fea6478F785A6d7e704777c86a7c6', --MAYC
        -- '\x34d85c9CDeB23FA97cb08333b511ac86E1C4E258', --Otherdeed
        '\xED5AF388653567Af2F388E6224dC7C4b3241C544', --Azuki
        '\x49cF6f5d44E70224e2E23fDcdd2C053F30aDA28B', --CloneX
        '\x8a90CAb2b38dba80c64b7734e58Ee1dB38B8992e', --Doodles
        -- '\x23581767a106ae21c074b2276D25e5C3e136a68b', --Moonbirds
        '\xa3AEe8BcE55BEeA1951EF834b99f3Ac60d1ABeeB', --Veefriends (VFT)
        '\xba30E5F9Bb24caa003E9f2f0497Ad287FDF95623', --BAKC
        '\xFF9C1b15B16263C61d017ee9F65C50e4AE0113D7', --Loot
        '\x1A92f7381B9F03921564a437210bB9396471050C' --Cool Cats
      )
    GROUP BY 
      1, 2
  )
SELECT 
  day,
  SUM(top_10_nft_median) AS index_price
FROM 
  t1
GROUP BY 
  1
ORDER BY 
  1 DESC;