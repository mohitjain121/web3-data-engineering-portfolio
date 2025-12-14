/* Description: 
  This query calculates the percentage of users for each program type in the Solana blockchain.
  It uses a Common Table Expression (CTE) to calculate the total number of users and then joins this with the main query to calculate the percentage of users for each program type.
*/

WITH 
total_users AS
(SELECT
      COUNT(DISTINCT account_keys[0]) AS total_users
    FROM
      solana.transactions
    WHERE
      array_contains(
        account_keys,
        'FarmqiPv5eAj3j1GMdMCMUGXqPUvmquZtMy86QH6rzhG'
      )
      AND success == true
      AND block_time >= '2022-07-01'
  )

SELECT
    program_type,
    count_users,
    percent_users
FROM
(SELECT
    CASE
        WHEN array_contains(account_keys, 'CuieVDEDtLo7FypA9SbLM9saXFdb1dsshEkyErMqkRQq') THEN 'Serum Bot'
  		WHEN array_contains(account_keys, 'Memo1UhkJRfHyvLMcVucJwxXeuD728EqVDDwQDxFMNo') THEN 'Memo'
  		WHEN array_contains(account_keys, '9xQeWvG816bUx9EPjHmaT23yvVM2ZWbrrpZb9PusVFin') THEN 'Serum DEX v3'
  		WHEN array_contains(account_keys, 'mv3ekLzLbnVPNxjSKvqBpU3ZeZXPQdEC3bp5MDEBG68') THEN 'Mango'
        WHEN array_contains(account_keys, '675kPX9MHTjS2zt1qfr1NYHuzeLXfQM9H24wFSUt1Mp8') THEN 'Raydium Liquidity Pool V4'
        WHEN array_contains(account_keys, 'EhhTKczWMGQt46ynNeRX1WfeagwwJd7ufHvCDjRxjo5Q') THEN 'Ray Staking'
        WHEN array_contains(account_keys, '9W959DqEETiGZocYWCQPaJ6sBmUzgfxXfqGeTEdp3aQP') THEN 'Orca Token Swap V2'
  		WHEN array_contains(account_keys, '9HzJyW1qZsEiSfMUf6L2jo3CcTKAyBmSyKdwQeYisHrC') THEN 'Raydium IDO'
  		WHEN array_contains(account_keys, 'FsJ3A3u2vn5cTVofAjvy6y5kwABJAqYWpe4975bi2epH') THEN 'Pyth Oracle Program'
  		WHEN array_contains(account_keys, 'CURVGoZn8zycx6FXwwevgBTB2gVvdbGTEpvMJDbgs2t4') THEN 'Aldring AMM V2'
  		WHEN array_contains(account_keys, '9W959DqEETiGZocYWCQPaJ6sBmUzgfxXfqGeTEdp3aQP') THEN 'Mango'
  		WHEN array_contains(account_keys, 'SSwpMgqNDsyV7mAgN9ady4bDVu5ySjmmXejXvy2vLt1') THEN 'Step Swap Program'
  		WHEN array_contains(account_keys, 'JUP2jxvXaqu7NQY1GmNF4m1vodw12LVXYxbFL2uJvfo') THEN 'Jupiter Aggregator v2'
  		WHEN array_contains(account_keys, 'DtmE9D2CSB4L5D6A15mraeEjrGMm6auWVzgaD8hK2tZM') THEN 'Switchboard Oracle'
  		WHEN array_contains(account_keys, 'ZETAxsqBRek56DhiGXrn75yj2NHU3aYUnxvHXpkf3aD') THEN 'Zeta DEX'
  		WHEN array_contains(account_keys, 'MEisE1HzehtrDpAAT8PnLHjpSSkRYakotTuJRPjTpo8') 
  		OR array_contains(account_keys, 'M2mx93ekt1fmXSVkTrUL9xVFHkmME8HTUi5Cyc5aF7K') THEN 'Magic Eden'
        WHEN array_contains(account_keys, 'So1endDq2YkqhipRh3WViPa8hdiSpxWy6z3Z6tMCpAo') THEN 'Solend'
  		WHEN array_contains(account_keys, 'KeccakSecp256k11111111111111111111111111111') THEN 'Secp256k1 Program'
        WHEN array_contains(account_keys, 'MemoSq4gqABAXKb96qnH8TysNcWxMyWCqXgDLGmfcHr') THEN 'Memo Program v2'
        WHEN array_contains(account_keys, 'cndy3Z4yapfJBmL3ShUp5exZKqR3z33thTzeNMm2gRZ') 
        OR array_contains(account_keys, 'cndyAnrLdpjq1Ssp1z8xxDsB8dxe7u4HL5Nxi2K5WXZ') THEN 'Metaplex NFT Candy Machine'
        WHEN array_contains(account_keys, 'CJsLwbP1iu5DuUikHEJnLfANgKy6stB2uFgvBBHoyxwz') THEN 'Solanart'
        WHEN (array_contains(account_keys, 'A7p8451ktDCHq5yYaHczeLMYsjRsAkzc3hCXcSrwYHU7')
        OR array_contains(account_keys, '7t8zVJtPCFAqog1DcnB6Ku1AVKtWfHkCiPi1cAvcJyVF')) THEN 'DigitalEyes'
        WHEN array_contains(account_keys, '617jbWo616ggkDxvW1Le8pV38XLbVSyWY8ae6QUmGBAU') THEN 'Solsea'
  		WHEN array_contains(account_keys, '7Sur3cy2efJGv8Qomn35p5k6HqMMcE8juWMBX8sCc96r')
  		  OR array_contains(account_keys, '2V7t5NaKY7aGkwytCWQgvUYZfEr9XMwNChhJEakTExk6')
  		  OR array_contains(account_keys, 'Y2akr3bXHRsqyP1QJtbm9G9N88ZV4t1KfaFeDzKRTfr')
  		  OR array_contains(account_keys, 'F42dQ3SMssashRsA4SRfwJxFkGKV1bE3TcmpkagX8vvX')
  		  OR array_contains(account_keys, 'FZsgu4Gv9fn1iUm5v7iW3p9joX9HJcmxgXdRCqCGxpfE')
  		  OR array_contains(account_keys, '26LYr2NRPprQ7aq6HTyAvrWxhouH8c9KLv1KumtRTJu2')
  		  OR array_contains(account_keys, 'HfeFy4G9r77iyeXdbfNJjYw4z3NPEKDL6YQh3JzJ9s9f')
  		  OR array_contains(account_keys, '9aiGb2qTGB7xxrEWRrHtzgzBYTfq4y51hQGHrYxxJWna') THEN 'Pyth Oracle Bot'
  		  ELSE 'Others'
  		  END AS program_type,
  		  COUNT(DISTINCT account_keys[0]) AS count_users,
  		  COUNT(DISTINCT account_keys[0])/total_users AS percent_users
    FROM solana.transactions, total_users
WHERE
    account_keys[0] IN (SELECT account_keys[0] FROM solana.transactions
    WHERE array_contains(account_keys, 'FarmqiPv5eAj3j1GMdMCMUGXqPUvmquZtMy86QH6rzhG')
    AND success == true
    AND block_time >= '2022-07-01')
    AND block_time >= '2022-05-01'
    AND success == true
  GROUP BY 1,total_users) x