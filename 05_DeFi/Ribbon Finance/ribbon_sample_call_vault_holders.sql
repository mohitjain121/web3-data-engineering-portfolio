/* Description: Calculate the percentage of holdings for each address in the vault and gauge */
WITH
  transfers_vault AS (
    SELECT
      evt_tx_hash AS tx_hash,
      tr."from" AS address,
      - tr.value AS amount,
      contract_address
    FROM
      erc20."ERC20_evt_Transfer" tr
    WHERE
      contract_address IN ('\x65a833afDc250D9d38f8CD9bC2B1E3132dB13B2F')
    UNION ALL
    SELECT
      evt_tx_hash AS tx_hash,
      tr."to" AS address,
      tr.value AS amount,
      contract_address
    FROM
      erc20."ERC20_evt_Transfer" tr
    WHERE
      contract_address IN ('\x65a833afDc250D9d38f8CD9bC2B1E3132dB13B2F')
  ),
  transfer_gauge AS (
    SELECT
      evt_tx_hash AS tx_hash,
      tr."from" AS address,
      - tr.value AS amount,
      contract_address
    FROM
      erc20."ERC20_evt_Transfer" tr
    WHERE
      contract_address IN ('\x8913eab16a302de3e498bba39940e7a55c0b9325')
    UNION ALL
    SELECT
      evt_tx_hash AS tx_hash,
      tr."to" AS address,
      tr.value AS amount,
      contract_address
    FROM
      erc20."ERC20_evt_Transfer" tr
    WHERE
      contract_address IN ('\x8913eab16a302de3e498bba39940e7a55c0b9325')
  ),
  transferAmounts AS (
    SELECT
      address,
      SUM(amount) / 1e8 AS vaultholdings
    FROM
      transfers_vault
    GROUP BY
      1
    UNION
    SELECT
      address,
      SUM(amount) / 1e8 AS vaultholdings
    FROM
      transfer_gauge
    GROUP BY
      1
  )
SELECT
  address,
  vaultholdings,
  (vaultholdings / SUM(vaultholdings) OVER ()) AS "% Held"
FROM
  transferAmounts
WHERE
  address != '\x8913eab16a302de3e498bba39940e7a55c0b9325'
  AND address != '\x0000000000000000000000000000000000000000'
  AND vaultholdings > 0.0001
GROUP BY
  vaultholdings,
  address
ORDER BY
  3 DESC;