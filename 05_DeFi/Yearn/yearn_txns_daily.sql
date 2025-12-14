/* Description: Aggregate ERC20 transfer events by day and transaction type. */

SELECT
  date_trunc('DAY', evt_block_time) AS datex,
  CASE
    WHEN "to" = '\x0000000000000000000000000000000000000000' THEN 'withdraw'
    WHEN "from" = '\x0000000000000000000000000000000000000000' THEN 'deposit'
  END AS txn_type,
  COUNT(DISTINCT evt_tx_hash) AS count_txns
FROM
  erc20."ERC20_evt_Transfer" t
WHERE
  t.contract_address IN (
    SELECT
      contract_address
    FROM
      yearn."yearn_all_vaults"
  )
GROUP BY
  date_trunc('DAY', evt_block_time),
  CASE
    WHEN "to" = '\x0000000000000000000000000000000000000000' THEN 'withdraw'
    WHEN "from" = '\x0000000000000000000000000000000000000000' THEN 'deposit'
  END