/* Description: Count users across various platforms */

WITH
  stader_users AS (
    SELECT
      "_account" AS wallet
    FROM
      stader_labs."BnbX_call_mint"
  ),
  stader AS (
    SELECT
      COUNT(DISTINCT wallet) AS stader_users
    FROM
      stader_users
  ),
  wombat AS 
  (SELECT COUNT(DISTINCT "from") AS wombat_users
  FROM
    bsc.transactions
    WHERE "to" = '\x312Bc7eAAF93f1C60Dc5AfC115FcCDE161055fb0'
    AND "from" IN (
      SELECT
        wallet
      FROM
        stader_users)
  ),
  ankr AS (
    SELECT
      COUNT(DISTINCT delegator) AS ankr_users
    FROM
      ankr."BinancePool_R4_evt_Staked"
    WHERE
      delegator IN (
        SELECT
          wallet
        FROM
          stader_users)
  ),
  pstake AS (
    SELECT
      COUNT(DISTINCT "to") AS pstake_users
    FROM
      bep20."BEP20_evt_Transfer"
    WHERE
      contract_address IN ('\xc2E9d07F66A89c44062459A47a0D2Dc038E4fb16')
      AND "from" = '\x0000000000000000000000000000000000000000'
      AND evt_block_time > '2022-08-01'
      AND "to" IN (
        SELECT
          wallet
        FROM
          stader_users)
  ),
  stepn AS (
    SELECT
      COUNT(DISTINCT "from") AS stepn_users
    FROM
      bsc."transactions"
    WHERE
      block_time >= '2022-04-01 00:00'
      AND "to" = '\x6238872a0bd9f0e19073695532a7ed77ce93c69e'
      AND "from" IN (
        SELECT
          wallet
        FROM
          stader_users)
  ),
  pancakeswap AS (
    SELECT
      COUNT(DISTINCT users) AS pancakeswap_users
    FROM
      (
        SELECT
          "sender" AS users
        FROM
          pancakeswap_v2."PancakePair_evt_Swap"
        UNION
        SELECT
          "to" AS users
        FROM
          pancakeswap_v2."PancakePair_evt_Swap"
      ) x
    WHERE
      users IN (
        SELECT
          wallet
        FROM
          stader_users)
  ),
  biswap AS (
    SELECT
      COUNT(DISTINCT users) AS biswap_users
    FROM
      (
        SELECT
          "sender" AS users
        FROM
          biswap."BiswapLPs_evt_Swap"
        UNION
        SELECT
          "to" AS users
        FROM
          biswap."BiswapLPs_evt_Swap"
      ) x
    WHERE
      users IN (
        SELECT
          wallet
        FROM
          stader_users)
  ),
  venus AS (
    SELECT
      COUNT(DISTINCT users) AS venus_users
    FROM
      (
        SELECT
          borrower as users
        FROM
          lending.borrow b
        UNION ALL
        select
          minter as users
        from
          venus."VBep20Delegate_evt_Mint"
        union all
        select
          minter as users
        from
          venus."VBNB_evt_Mint"
      ) x
    WHERE
      users IN (
        SELECT
          wallet
        FROM
          stader_users)
  ),
  tofunft AS (
    SELECT
      COUNT(DISTINCT "from") AS tofunft_users
    FROM
      bsc.transactions
    WHERE
      "to" in (
        '\x449D05C544601631785a7C062DCDFF530330317e',
        '\x449D05C544601631785a7C062DCDFF530330317e'
      ) -- tofunft
      AND block_time >= '2022-04-01 00:00'
      AND "from" IN (
        SELECT
          wallet
        FROM
          stader_users)
  ),
  nftrade AS (
    SELECT
      COUNT(DISTINCT "from") AS nftrade_users
    FROM
      bsc.transactions
    WHERE
      "to" in (
        '\xE05D2BAA855C3dBA7b4762D2f02E9012Fb5F3867',
        '\x2559Be60A7040D645D263cA54c936320f90be74b',
        '\x295f911ccb8C771593375a4e8969A124bad725d8',
        '\xf1899184bF3d26c4Db243C3B803501FC3E6cb388',
        '\xcFB6Ee27d82beb1B0f3aD501B968F01CD7Cc5961',
        '\x3e9F9dfADFde30786D2F9D8e1cF8d773868Ba096',
        '\xe3E07c41509DA07bEA55B80dCeA85fFFB18a1FaB',
        '\x727B32e57EC4a751507d1aB745404cbAe480deB6',
        '\xc28F1550160478a7FB3b085F25d4b179E08E649a',
        '\x71c82Fdbbdb6fb641f680087DA5aBEFFDDfE66a3',
        '\xcEcC2d4E3E6590b9cb9f662f62171f441cbCa40C'
      ) --nftrade
      AND block_time >= '2022-04-01 00:00'
      AND "from" IN (
        SELECT
          wallet
        FROM
          stader_users)
  ),
  bitkeep_nft AS (
    SELECT
      COUNT(DISTINCT "from") AS bitkeep_nft_users
    FROM
      bsc.transactions
    WHERE
      "to" in (
        '\x73F7Edc2C4E3dbb0728184e1eF565d3e05EfBc05',
        '\xB803340c7105F9f884Fd237762A2A003bba91193',
        '\xA1a06e49024B87e58C82e8F734c7120fF34d8432'
      ) --bitkeep nft market
      AND block_time >= '2022-04-01 00:00'
      AND "from" IN (
        SELECT
          wallet
        FROM
          stader_users)
  )
SELECT
  stader_users,
  wombat_users,
  ankr_users,
  pancakeswap_users,
  pstake_users,
  venus_users,
  stepn_users,
  biswap_users,
  nftrade_users,
  tofunft_users,
  bitkeep_nft_users
FROM
  stader,
  ankr,
  pancakeswap,
  pstake,
  venus,
  stepn,
  biswap,
  nftrade,
  tofunft,
  bitkeep_nft,
  wombat