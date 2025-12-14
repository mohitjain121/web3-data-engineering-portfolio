/* Description: Calculate NFT index price based on top 10 NFT median prices and ETH price. */

WITH 
eth_price AS (
    SELECT
        DATE_TRUNC('DAY', hour) AS day,
        AVG(median_price) AS eth_price
    FROM 
        prices."prices_from_dex_data"
    WHERE 
        symbol = 'WETH' --WETH
        AND hour > NOW() - INTERVAL '6 MONTHS'
    GROUP BY 1
),

nft_index_price AS 
(
    SELECT
        day,
        SUM(top_10_nft_median) AS nft_index_price
    FROM
    (
        SELECT
          nft_contract_address,
          DATE_TRUNC('DAY', block_time) AS day,
          PERCENTILE_CONT(0.1) WITHIN GROUP (
            ORDER BY
              original_amount
          ) AS top_10_nft_median
        FROM
          nft.trades
        WHERE
          nft_token_id IS NOT NULL
          AND original_currency IN ('ETH', 'WETH')
          AND block_time > NOW() - INTERVAL '6 MONTHS'
          AND nft_contract_address IN (
            '\xBC4CA0EdA7647A8aB7C2061c2E118A18a936f13D', --BAYC
            '\xb47e3cd837dDF8e4c57F05d70Ab865de6e193BBB', --CryptoPunks
            '\x60E4d786628Fea6478F785A6d7e704777c86a7c6', --MAYC
            '\xED5AF388653567Af2F388E6224dC7C4b3241C544', --Azuki
            '\x49cF6f5d44E70224e2E23fDcdd2C053F30aDA28B', --CloneX
            '\x8a90CAb2b38dba80c64b7734e58Ee1dB38B8992e', --Doodles
            '\xa3AEe8BcE55BEeA1951EF834b99f3Ac60d1ABeeB', --Veefriends (VFT)
            '\xba30E5F9Bb24caa003E9f2f0497Ad287FDF95623', --BAKC
            '\xFF9C1b15B16263C61d017ee9F65C50e4AE0113D7', --Loot
            '\x1A92f7381B9F03921564a437210bB9396471050C', --Cool Cats
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
            '\x797a48c46Be32aafceDcFD3d8992493D8A1F256b' --pixel vault minipass
          )
        GROUP BY
          1,
          2
    ) x
    GROUP BY 1
)

SELECT 
    COALESCE(a.day, b.day) AS day,
    eth_price,
    nft_index_price * eth_price AS nft_index_price
FROM 
    eth_price a
    FULL JOIN nft_index_price b ON a.day = b.day