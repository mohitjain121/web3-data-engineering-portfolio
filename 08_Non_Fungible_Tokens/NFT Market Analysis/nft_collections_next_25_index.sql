/* Description: Calculate the floor price of NFTs by week. */
WITH 
  t1 AS (
    SELECT 
      nft_contract_address,
      date_trunc('WEEK', block_time) AS day,
      percentile_cont(.1) WITHIN GROUP (
        ORDER BY 
          original_amount
      ) AS nft_median
    FROM 
      nft.trades
    WHERE 
      nft_token_id IS NOT NULL
      AND original_currency IN ('ETH', 'WETH')
      AND date_trunc('DAY', block_time) > date_trunc('DAY', NOW()) - INTERVAL '6 MONTHS'
      AND date_trunc('DAY', block_time) < date_trunc('DAY', NOW())
      AND nft_contract_address IN (
        '\xFb3765E0E7AC73E736566AF913FA58c3cFD686b7', --audioglyphs
        '\xe785E82358879F061BC3dcAC6f0444462D4b5330', --World of Women (WOW)
        '\x1CB1A5e65610AEFF2551A50f76a87a7d3fB649C6', -- CrypToadz by GREMPLIN 18
        '\x57a204AA1042f6E66DD7730813f4024114d74f37', --66 Cyberkongz
        '\x76BE3b62873462d2142405439777e971754E8E77', --parallel alpha
        '\xBd3531dA5CF5857e7CfAA92426877b022e612cf8', --pudgypenguins
        '\x9A534628B4062E123cE7Ee2222ec20B86e16Ca8F', --mekaverse
        '\x22c36BfdCef207F9c0CC941936eff94D4246d14A', --bored ape chemistry club
        '\xBD4455dA5929D5639EE098ABFaa3241e9ae111Af', --NFT Worlds
        '\x3bf2922f4520a8BA0c2eFC3D2a1539678DaD5e9D', --on1 force
        '\x28472a58A490c5e09A238847F66A68a47cC76f0f', --adidas originals
        '\x79FCDEF22feeD20eDDacbB2587640e45491b757f', --mfers
        '\xCcc441ac31f02cD96C153DB6fd5Fe0a2F4e6A68d', --fluf world
        '\xc92cedDfb8dd984A89fb494c376f9A48b999aAFc', --creature world
        '\x67D9417C9C3c250f61A83C7e8658daC487B56B09', --phantabear
        '\x82C7a8f707110f5FBb16184A5933E9F78a34c6ab', --emblem avult
        '\x0c2E57EFddbA8c768147D1fdF9176a0A6EBd5d83', --kaiju kings
        '\xfE8C6d19365453D26af321D0e8c910428c23873F', --Creepz genesis
        '\x123b30E25973FeCd8354dd5f41Cc45A3065eF88C', --alien frenz
        '\x4Db1f25D3d98600140dfc18dEb7515Be5Bd293Af', --hape prime
        '\xc36cF0cFcb5d905B8B513860dB0CFE63F6Cf9F5c', --town star
        '\x73DA73EF3a6982109c4d5BDb0dB9dd3E3783f313', --curio cards
        '\x8943C7bAC1914C9A7ABa750Bf2B6B09Fd21037E0', --lazy lion
        '\x797a48c46Be32aafceDcFD3d8992493D8A1F256b'  --pixel vault minipass
      )
    GROUP BY 
      1, 2
  )
SELECT 
  day,
  SUM(t1.nft_median) AS floor_price
FROM 
  t1
GROUP BY 
  1
ORDER BY 
  1;