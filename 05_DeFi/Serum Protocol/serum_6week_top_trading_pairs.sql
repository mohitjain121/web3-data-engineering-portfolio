/* Description: Count transactions by Serum pool */
SELECT 
    CASE 
        WHEN array_contains(account_keys, '9wFFyRfZBsuAha4YcuxcXLKwMxJR43S7fPfQLusDBzvT') THEN 'SOL-USDC'
            WHEN array_contains(account_keys, 'C6tp2RVZnxBPFbnAsfTjis8BN9tycESAT4SgDQgbbrsA') THEN 'RAY-SOL'
            WHEN array_contains(account_keys, '2xiv8A5xrJ7RnGdxXB42uFEkYHJjszEhaJyKKt4WaLep') THEN 'RAY-USDC'
            WHEN array_contains(account_keys, '7gtMZphDnZre32WfedWnDLhYYWJ2av1CCn1RES5g8QUf') THEN 'ETH-SOL'
            WHEN array_contains(account_keys, 'HWHvQhFmJB3NUcu1aihKmrKegfVxBEHzwVX6yZCKEsi1') THEN 'SOL-USDT'
            WHEN array_contains(account_keys, '6jx6aoNFbmorwyncVP5V5ESKfuFc9oUYebob1iF6tgN4') THEN 'RAY-soETH'
            WHEN array_contains(account_keys, 'teE55QrL4a4QSfydR9dnHF97jgCfptpuigbb53Lo95g') THEN 'RAY-USDT'
            WHEN array_contains(account_keys, '8Gmi2HhZmwQPVdCwzS7CM66MGstMXPcTVHA7jF19cLZz') THEN 'ETH-USDC'
            WHEN array_contains(account_keys, 'Cm4MmknScg7qbKqytb1mM92xgDxv3TNXos4tKbBqTDy7') THEN 'RAY-SRM'
            WHEN array_contains(account_keys, '77quYg4MGneUdjgXCunt9GgM1usmrxKY31twEy3WHwcS') THEN 'USDT-USDC'
            WHEN array_contains(account_keys, 'ch7kmPrtoQUSEPBggcNAvLGiMQkJagVwd3gDYfd8m7Q') THEN 'ETH-USDT'
            WHEN array_contains(account_keys, 'FwZ2GLyNNrFqXrmR8Sdkm9DQ61YnQmxS6oobeH3rrLUM') THEN 'GENE-USDC'
            WHEN array_contains(account_keys, '49vwM54DX3JPXpey2daePZPmimxA4CrkXLZ6E1fGxx2Z') THEN 'IN-USDC'
            WHEN array_contains(account_keys, '6oGsL2puUgySccKzn9XA9afqF217LfxP5ocq4B3LWsjy') THEN 'mSOL-USDC'
            WHEN array_contains(account_keys, '5F7LGsP1LPtaRV7vVKgxwNYX4Vf22xvuzyXjyar7jJqp') THEN 'stSOL-USDC'
            WHEN array_contains(account_keys, 'Bn7n597jMxU4KjBPUo3QwJhbqr5145cHy31p6EPwPHwL') THEN 'ATLAS-RAY'
            WHEN array_contains(account_keys, 'FDkK55eE6Ro9mURo4YGgHafL3D5NW8yhnkUAFFoJB8SD') THEN 'stSOL-USDT'
            WHEN array_contains(account_keys, '2JiQd14xAjmcNEJicyU1m3TVbzQDktTvY285gkozD46J') THEN 'GST-USDC'
            WHEN array_contains(account_keys, 'A8YFbxQYFVqKZaoYJLLUVcQiWP7G2MeEgW5wsAQgMvFw') THEN 'BTC-USDC'
            WHEN array_contains(account_keys, '7KQpsp914VYnh62yV6AGfoG9hprfA14SgzEyqr6u9NY1') THEN 'UXP-USDC'
            WHEN array_contains(account_keys, 'DpFKTy69uZv2G6KW7b117axwQRSztH5g4gUtBPZ9fCS7') THEN 'GENE-RAY'
            WHEN array_contains(account_keys, 'GekRdc4eD9qnfPTjUMK5NdQDho8D9ByGrtnqhMNCTm36') THEN 'SLIM-SOL'
            WHEN array_contains(account_keys, 'HxFLKUAmAMLz1jtT3hbvCMELwH5H9tpM2QugP8sKyfhW') THEN 'POLIS-USDC'
            WHEN array_contains(account_keys, '3UP5PuGN6db7NhWf4Q76FLnR4AguVFN14GvgDbDj1u7h') THEN 'POLIS-RAY'
            WHEN array_contains(account_keys, '4tSvZvnbyzHXLMTiFonMyxZoHmFqau1XArcRCVHLZ5gX') THEN 'soETH-USDC'
            WHEN array_contains(account_keys, 'HkLEttvwk2b4QDAHzNcVtxsvBG35L1gmYY4pecF9LrFe') THEN 'soETH-SOL'
            WHEN array_contains(account_keys, 'AAfgwhNU5LMjHojes1SFmENNjihQBDKdDDT1jog4NV8w') THEN 'SAMO-RAY'
            WHEN array_contains(account_keys, 'C3c2NZurMhwrgMAaUXewjDGTy5f93MvYbhYCYfXXmnZN') THEN 'ZBC-USDC'
            WHEN array_contains(account_keys, 'C1EuT9VokAKLiW7i2ASnZUvxDoKuKkCpDDeNxAptuNe4') THEN 'BTC-USDT'
            WHEN array_contains(account_keys, '3uWVMWu7cwMnYMAAdtsZNwaaqeeeZHARGZwcExnQiFay') THEN 'SUSHI-USDC'
            WHEN array_contains(account_keys, '7dLVkUfBVfCGkFhSXDCq1ukM9usathSgS716t643iFGF') THEN 'soETH-USDT'
            WHEN array_contains(account_keys, '2Pbh1CvRVku1TgewMfycemghf6sU9EyuFDcNXqvRmSxc') THEN 'soFTT-USDC'
            WHEN array_contains(account_keys, 'AU8VGwd4NGRbcMz9LT6Fu2LP69LPAbWUJ6gEfEgeYM33') THEN 'REAL-USDC'
            WHEN array_contains(account_keys, 'F9y9NM83kBMzBmMvNT18mkcFuNAPhNRhx7pnz9EDWwfv') THEN 'SLND-USDC'
            WHEN array_contains(account_keys, '4VKLSYdvrQ5ngQrt1d2VS8o4ewvb2MMUZLiejbnGPV33') THEN 'MSRM-USDC'
            WHEN array_contains(account_keys, '5nLJ22h1DUfeCfwbFxPYK8zbfbri7nA9bXoDcR8AcJjs') THEN 'MSRM-USDT'
            WHEN array_contains(account_keys, '9UBuWgKN8ZYXcZWN67Spfp3Yp67DKBq1t31WLrVrPjTR') THEN 'DFL-USDC'
            WHEN array_contains(account_keys, 'HxkQdUnrPdHwXP5T9kewEXs3ApgvbufuTfdw9v1nApFd') THEN 'mSOL-USDT'

        ELSE "Others" 
        END AS Serum_Pool,
    COUNT(id) AS count_txns
FROM `solana`.`transactions`

WHERE 
    block_date > NOW() - INTERVAL '6 WEEKS' AND
    ARRAY_CONTAINS(account_keys, '9xQeWvG816bUx9EPjHmaT23yvVM2ZWbrrpZb9PusVFin')
    AND success = TRUE
GROUP BY 1
ORDER BY 2 DESC