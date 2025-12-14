/* Description: Calculate the percentage of tokens held by top wallets in each vault. */

WITH
  decimals AS (
    SELECT
      'AAVE v2 Call' AS vault_name,
      'AAVE' AS token,
      '\xe63151A0Ed4e5fafdc951D877102cf0977Abd365':: BYTEA AS contract_address,
      18 AS decimals
    UNION
    SELECT
      'ryvUSDC v2 Eth Put' AS vault_name,
      'USDC' AS token,
      '\xCc323557c71C0D1D20a1861Dc69c06C5f3cC9624':: BYTEA AS contract_address,
      6 AS decimals
    UNION
    SELECT
      'rETH v2 Call' AS vault_name,
      'WETH' AS token,
      '\x25751853Eab4D0eB3652B5eB6ecB102A2789644B':: BYTEA AS contract_address,
      18 AS decimals
    UNION
    SELECT
      'stETh Theta V2 Call' AS vault_name,
      'WETH' AS token,
      '\x53773E034d9784153471813dacAFF53dBBB78E8c':: BYTEA AS contract_address,
      18 AS decimals
    UNION
    SELECT
      'BTC Theta V2 Call' AS vault_name,
      'WBTC' AS token,
      '\x65a833afDc250D9d38f8CD9bC2B1E3132dB13B2F':: BYTEA AS contract_address,
      8 AS decimals
    UNION
    SELECT
      'ryvUSDC Eth v1 Put' AS vault_name,
      'USDC' AS token,
      '\x8FE74471F198E426e96bE65f40EeD1F8BA96e54f':: BYTEA AS contract_address,
      6 AS decimals
    UNION
    SELECT
      'rETH Theta V1 Call' AS vault_name,
      'WETH' AS token,
      '\x0FABaF48Bbf864a3947bdd0Ba9d764791a60467A':: BYTEA AS contract_address,
      18 AS decimals
    UNION
    SELECT
      'rBTC Theta V1 Call' AS vault_name,
      'WBTC' AS token,
      '\x8b5876f5B0Bf64056A89Aa7e97511644758c3E8c':: BYTEA AS contract_address,
      8 AS decimals
    UNION
    SELECT
      'rUSDC ETh V1 Put' AS vault_name,
      'USDC' AS token,
      '\x16772a7f4a3ca291C21B8AcE76F9332dDFfbb5Ef':: BYTEA AS contract_address,
      6 AS decimals
  ),
  wallets AS (
    SELECT
      CONCAT(
        '<a href="https://etherscan.io/address/0',
        SUBSTRING(wallet:: text, 2),
        '" target="_blank" >',
        wallet,
        '</a>'
      ) AS wallet,
      vault,
      SUM(value) as staked_balance
    FROM
      (
        SELECT
          "from" AS wallet,
          -- Unstake
          (-1) * value AS value,
          CASE
            WHEN contract_address = '\xe63151A0Ed4e5fafdc951D877102cf0977Abd365' THEN 'AAVE v2 Call'
            WHEN contract_address = '\xCc323557c71C0D1D20a1861Dc69c06C5f3cC9624' THEN 'ryvUSDC v2 Eth Put'
            WHEN contract_address = '\x25751853Eab4D0eB3652B5eB6ecB102A2789644B' THEN 'rETH v2 Call'
            WHEN contract_address = '\x53773E034d9784153471813dacAFF53dBBB78E8c' THEN 'stETh Theta V2 Call'
            WHEN contract_address = '\x44017598f2AF1bD733F9D87b5017b4E7c1B28DDE' THEN 'BTC Theta V2 Call'
            WHEN contract_address = '\x8FE74471F198E426e96bE65f40EeD1F8BA96e54f' THEN 'ryvUSDC Eth v1 Put'
            WHEN contract_address = '\x0FABaF48Bbf864a3947bdd0Ba9d764791a60467A' THEN 'rETH Theta V1 Call'
            WHEN contract_address = '\x8b5876f5B0Bf64056A89Aa7e97511644758c3E8c' THEN 'rBTC Theta V1 Call'
            WHEN contract_address = '\x16772a7f4a3ca291C21B8AcE76F9332dDFfbb5Ef' THEN 'rUSDC ETh V1 Put'
            ELSE 'Others'
          END AS vault
        FROM
          erc20."ERC20_evt_Transfer"
        WHERE
          contract_address IN (
            '\xe63151A0Ed4e5fafdc951D877102cf0977Abd365',
            '\xCc323557c71C0D1D20a1861Dc69c06C5f3cC9624',
            '\x25751853Eab4D0eB3652B5eB6ecB102A2789644B',
            '\x53773E034d9784153471813dacAFF53dBBB78E8c',
            '\x65a833afDc250D9d38f8CD9bC2B1E3132dB13B2F',
            '\x8FE74471F198E426e96bE65f40EeD1F8BA96e54f',
            '\x0FABaF48Bbf864a3947bdd0Ba9d764791a60467A',
            '\x8b5876f5B0Bf64056A89Aa7e97511644758c3E8c',
            '\x16772a7f4a3ca291C21B8AcE76F9332dDFfbb5Ef'
          )
        UNION
        SELECT
          "to" AS wallet,
          -- Stake
          value AS value,
          CASE
            WHEN contract_address = '\xe63151A0Ed4e5fafdc951D877102cf0977Abd365' THEN 'AAVE v2 Call'
            WHEN contract_address = '\xCc323557c71C0D1D20a1861Dc69c06C5f3cC9624' THEN 'ryvUSDC v2 Eth Put'
            WHEN contract_address = '\x25751853Eab4D0eB3652B5eB6ecB102A2789644B' THEN 'rETH v2 Call'
            WHEN contract_address = '\x53773E034d9784153471813dacAFF53dBBB78E8c' THEN 'stETh Theta V2 Call'
            WHEN contract_address = '\x44017598f2AF1bD733F9D87b5017b4E7c1B28DDE' THEN 'BTC Theta V2 Call'
            WHEN contract_address = '\x8FE74471F198E426e96bE65f40EeD1F8BA96e54f' THEN 'ryvUSDC Eth v1 Put'
            WHEN contract_address = '\x0FABaF48Bbf864a3947bdd0Ba9d764791a60467A' THEN 'rETH Theta V1 Call'
            WHEN contract_address = '\x8b5876f5B0Bf64056A89Aa7e97511644758c3E8c' THEN 'rBTC Theta V1 Call'
            WHEN contract_address = '\x16772a7f4a3ca291C21B8AcE76F9332dDFfbb5Ef' THEN 'rUSDC ETh V1 Put'
            ELSE 'Others'
          END AS vault
        FROM
          erc20."ERC20_evt_Transfer"
        WHERE
          contract_address IN (
            '\xe63151A0Ed4e5fafdc951D877102cf0977Abd365',
            '\xCc323557c71C0D1D20a1861Dc69c06C5f3cC9624',
            '\x25751853Eab4D0eB3652B5eB6ecB102A2789644B',
            '\x53773E034d9784153471813dacAFF53dBBB78E8c',
            '\x65a833afDc250D9d38f8CD9bC2B1E3132dB13B2F',
            '\x8FE74471F198E426e96bE65f40EeD1F8BA96e54f',
            '\x0FABaF48Bbf864a3947bdd0Ba9d764791a60467A',
            '\x8b5876f5B0Bf64056A89Aa7e97511644758c3E8c',
            '\x16772a7f4a3ca291C21B8AcE76F9332dDFfbb5Ef'
          )
      ) c
    WHERE
      wallet NOT IN (
        '\x0000000000000000000000000000000000000000',
        '\x0000000000000000000000000000000000000001',
        '\x000000000000000000000000000000000000dead'
      )
    GROUP BY
      1,
      2
    ORDER BY
      2 DESC
  ),
  wallet_rank AS (
    SELECT
      wallet,
      vault,
      staked_balance,
      SUM(staked_balance) OVER (
        PARTITION BY vault
        ORDER BY
          staked_balance DESC
      ) AS cum_wallet_holdings,
      DENSE_RANK() OVER (
        PARTITION BY vault
        ORDER BY
          staked_balance DESC
      ) AS wallet_rank
    FROM
      wallets
    WHERE
      staked_balance > 0.00001
    GROUP BY
      1,
      2,
      3
  ),
  vault_rank AS (
    SELECT
      vault,
      SUM(staked_balance) as cir_supply,
      COUNT(DISTINCT wallet) as no_holders
    FROM
      wallet_rank
    GROUP BY
      1
  )
SELECT
  w.vault,
  --   v.cir_supply/10^d.decimals as total_tokens,
  SUM(
    CASE
      WHEN w.wallet_rank:: float / nullif(v.no_holders:: float, 0) <= 0.01 THEN w.staked_balance:: float
      ELSE NULL
    END
  ) / v.cir_supply:: float AS "% vault held by top 1%",
  SUM(
    CASE
      WHEN w.wallet_rank:: float / nullif(v.no_holders:: float, 0) <= 0.05 THEN w.staked_balance:: float
      ELSE NULL
    END
  ) / v.cir_supply:: float AS "% vault held by top 5%",
  SUM(
    CASE
      WHEN w.wallet_rank:: float / nullif(v.no_holders:: float, 0) <= 0.10 THEN w.staked_balance:: float
      ELSE NULL
    END
  ) / v.cir_supply:: float AS "% vault held by top 10%" -- SUM(CASE WHEN w.wallet_rank = ROUND(v.no_holders/2,2) THEN w.staked_balance ELSE NULL END ) as "Median token balance"
FROM
  wallet_rank w
  JOIN vault_rank v ON v.vault = w.vault
  JOIN decimals d ON w.vault = d.vault_name
GROUP BY
  1,
  v.cir_supply