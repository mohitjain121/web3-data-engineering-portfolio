/* Description: Calculate daily transactions and asset changes for various vaults. */

SELECT
  date_trunc('DAY', evt_block_time) AS datex,
  vault_name,
  COUNT(
    CASE
      WHEN "from" = '\x0000000000000000000000000000000000000000' THEN evt_tx_hash
      WHEN "to" = '\x0000000000000000000000000000000000000000' THEN evt_tx_hash
      ELSE NULL
    END
  ) AS "Total Transactions",
  COUNT(
    CASE
      WHEN "from" = '\x0000000000000000000000000000000000000000' THEN evt_tx_hash
    END
  ) AS "Deposits Daily",
  COUNT(
    CASE
      WHEN "to" = '\x0000000000000000000000000000000000000000' THEN evt_tx_hash
    END
  ) AS "Withdrawals Daily",
  SUM(
    CASE
      WHEN "from" = '\x0000000000000000000000000000000000000000' THEN value / 10 ^ (decimals)
    END
  ) AS "Deposit Amount",
  SUM(
    CASE
      WHEN "to" = '\x0000000000000000000000000000000000000000' THEN value / 10 ^ (decimals)
    END
  ) AS "Withdrawal Amount",
  SUM(
    CASE
      WHEN "from" = '\x0000000000000000000000000000000000000000' THEN value / 10 ^ (decimals)
      WHEN "to" = '\x0000000000000000000000000000000000000000' THEN (-1)*value / 10 ^ (decimals)
    END
  ) AS "Net Asset Change"
FROM
  decimals d
  INNER JOIN erc20."ERC20_evt_Transfer" t ON t.contract_address = d.contract_address
WHERE
  t.contract_address IN (
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
GROUP BY
  1,
  2
ORDER BY
  1 DESC;