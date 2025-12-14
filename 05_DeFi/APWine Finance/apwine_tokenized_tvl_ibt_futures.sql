/* Description: Calculate token TVL and dollar-IBT for various vaults. */

WITH
  decimals AS (
    SELECT
      'SDT-StakeDAO' AS vault_name,
      '\xaC14864ce5A98aF3248Ffbf549441b04421247D3':: BYTEA AS contract_address,
      --SDT
      18 AS decimals
    UNION
    SELECT
      'USDC-TrueFi' AS vault_name,
      '\xa991356d261fbaf194463af6df8f0464f8f1c742':: BYTEA AS contract_address,
      --true_fi_usdc
      6 AS decimals
    UNION
    SELECT
      'StkAAVE-Paladin' AS vault_name,
      '\x24E79e946dEa5482212c38aaB2D0782F04cdB0E0':: BYTEA AS contract_address,
      --stkAAVE
      18 AS decimals
    UNION
    SELECT
      'frax3crv-IDLE' AS vault_name,
      '\x15794da4dcf34e674c18bbfaf4a67ff6189690f5':: BYTEA AS contract_address,
      --idle_aa_frax3crv
      18 AS decimals
    UNION
    SELECT
      'PSP4-Paraswap' AS vault_name,
      '\x6b1D394Ca67fDB9C90BBd26FE692DdA4F4f53ECD':: BYTEA AS contract_address,
      --paraswap_psp4
      18 AS decimals
    UNION
    SELECT
      'PSP3-Paraswap' AS vault_name,
      '\xea02df45f56a690071022c45c95c46e7f61d3eab':: BYTEA AS contract_address,
      --paraswap_psp3
      18 AS decimals
    UNION
    SELECT
      'frax-StakeDAO' AS vault_name,
      '\x5af15da84a4a6edf2d9fa6720de921e1026e37b7':: BYTEA AS contract_address,
      --Stake DAO Frax
      18 AS decimals
    UNION
    SELECT
      'Sushi-Sushi' AS vault_name,
      '\x8798249c2e607446efb7ad49ec89dd1865ff4272':: BYTEA AS contract_address,
      --sushi_sushi
      18 AS decimals
    UNION
    SELECT
      'OHM-Olympus' AS vault_name,
      '\x0ab87046fbb341d058f17cbc4c1133f25a20a52f':: BYTEA AS contract_address,
      --olympus_ohm
      18 AS decimals
    UNION
    SELECT
      'ibEUR-Yearn' AS vault_name,
      '\x67e019bfbd5a67207755D04467D6A70c0B75bF60':: BYTEA AS contract_address,
      --yearn_ibeur
      18 AS decimals
    UNION
    SELECT
      'FARM-Harvest' AS vault_name,
      '\x1571ed0bed4d987fe2b498ddbae7dfa19519f651':: BYTEA AS contract_address,
      --harvest_farm
      18 AS decimals
    UNION
    SELECT
      'c3Crypto-Yearn' AS vault_name,
      '\xe537b5cc158eb71037d4125bdd7538421981e6aa':: BYTEA AS contract_address,
      --yearn_a3crypto
      18 AS decimals
    UNION
    SELECT
      'ib3Crv-Yearn' AS vault_name,
      '\x27b7b1ad7288079a66d12350c828d3c00a6f07d7':: BYTEA AS contract_address,
      --yearn_crvib
      18 AS decimals
    UNION
    SELECT
      'wETH-Lido' AS vault_name,
      '\xae7ab96520de3a18e5e111b5eaab095312d7fe84':: BYTEA AS contract_address,
      --steth
      18 AS decimals
    UNION
    SELECT
      'USDT-AAVE' AS vault_name,
      '\x3Ed3B47Dd13EC9a98b44e6204A523E766B225811':: BYTEA AS contract_address,
      --aUSDT
      6 AS decimals
  ),
  txns AS (
    SELECT
      DATE_TRUNC('DAY', evt_block_time) AS datex,
      "to" AS vault,
      contract_address,
      SUM(value) AS amount
    FROM
      erc20."ERC20_evt_Transfer"
    WHERE
      "to" IN (
        '\x1d220bd76c2f004bde2958c643173189d8db3a7a',
        '\xb9df660caaa62d47df265a469c8b77f661efc18d',
        '\x10f29cf8e6ba81363a330c50f74900d03cd6324d',
        '\x7348f3bd4747ffe142ed54105962e361ddd0db11',
        '\xb524c16330a76182ef617f08f5e6996f577ac64a',
        '\x0fd13dca30ee1b988dbdf1374c1561141385bee6',
        '\x609ebd0a8b06dabb805f1e64b35301c185d94f95',
        '\xbd0ba083aca48bf6be034890006e92b874783365',
        '\x894d7e0f2ecff866275a5a09ec6d44714fc74c35',
        '\x8e6ca2b63b0c231364f85c42bcfc9d0a49786e62',
        '\x261ca4e645578a9ed304ac98d5243ebb518a162d',
        '\x35bbdc3fbdc26f7dfee5670af50b93c7eabce2c0',
        '\x19481d0b3177aedec70b8339f0706a79b9845be7',
        '\xa0ed6dad3219442224d86faec532f890cabf1483',
        '\x6fb566cb80a5038bbe0421a91d9f96f9bb9d6d95'
      )
    GROUP BY
      1,
      2,
      3
    UNION
    SELECT
      DATE_TRUNC('DAY', evt_block_time) AS datex,
      "from" AS vault,
      contract_address,
      SUM((-1) * value) AS amount
    FROM
      erc20."ERC20_evt_Transfer"
    WHERE
      "from" IN (
        '\x1d220bd76c2f004bde2958c643173189d8db3a7a',
        '\xb9df660caaa62d47df265a469c8b77f661efc18d',
        '\x10f29cf8e6ba81363a330c50f74900d03cd6324d',
        '\x7348f3bd4747ffe142ed54105962e361ddd0db11',
        '\xb524c16330a76182ef617f08f5e6996f577ac64a',
        '\x0fd13dca30ee1b988dbdf1374c1561141385bee6',
        '\x609ebd0a8b06dabb805f1e64b35301c185d94f95',
        '\xbd0ba083aca48bf6be034890006e92b874783365',
        '\x894d7e0f2ecff866275a5a09ec6d44714fc74c35',
        '\x8e6ca2b63b0c231364f85c42bcfc9d0a49786e62',
        '\x261ca4e645578a9ed304ac98d5243ebb518a162d',
        '\x35bbdc3fbdc26f7dfee5670af50b93c7eabce2c0',
        '\x19481d0b3177aedec70b8339f0706a79b9845be7',
        '\xa0ed6dad3219442224d86faec532f890cabf1483',
        '\x6fb566cb80a5038bbe0421a91d9f96f9bb9d6d95'
      )
    GROUP BY
      1,
      2,
      3
  ),
  generateDummyData AS (
    SELECT
      DISTINCT vault,
      contract_address,
      "generated_date",
      0 as "amount"
    FROM
      txns
      CROSS JOIN generate_series('2021-12-23', NOW(), '1 day') as "generated_date"
  ),
  token_tvl AS (
    SELECT
      "datex",
      "vault",
      vault_name,
      "contract_address",
      "amount" / POWER(10, decimals) AS "daily_amount",
      SUM("amount" / POWER(10, decimals)) OVER (
        PARTITION BY "vault",
        "contract_address"
        ORDER BY
          "datex"
      ) AS token_tvl
    FROM (
      SELECT
        *
      FROM
        txns
      UNION ALL
      SELECT
        "generated_date",
        "vault",
        "contract_address",
        "amount"
      FROM
        generateDummyData
    ) x
    LEFT JOIN decimals USING ("contract_address")
    GROUP BY
      1,
      2,
      3,
      4,
      5,
      decimals,
      contract_address
  )
SELECT
  t.datex,
  vault_name,
  t.contract_address,
  -- price,
  daily_amount,
  token_tvl,
  token_tvl * price AS dollar_ibt
FROM
  token_tvl t
  LEFT JOIN dune_user_generated.apwine_ibt_prices_ethereum p
  ON t.datex = p.datex
  AND t.contract_address = p.contract_address
ORDER BY
  1 DESC;