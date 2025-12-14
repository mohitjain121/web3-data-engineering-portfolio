/* Description: Count active and total wallets based on ERC20 transfer events. */

SELECT
  COUNT(
    DISTINCT CASE
      WHEN wallet_balance > 0 THEN wallet
      ELSE NULL
    END
  ) AS "active_wallets",
  COUNT(DISTINCT wallet) AS "total_wallets"
FROM (
  SELECT
    wallet,
    SUM(value) AS wallet_balance
  FROM (
    SELECT
      "from" AS wallet,
      (-1) * value AS value
    FROM
      erc20."ERC20_evt_Transfer"
    WHERE
      contract_address IN (
        '\x44017598f2AF1bD733F9D87b5017b4E7c1B28DDE',
        '\x45e007750Cc74B1D2b4DD7072230278d9602C499',
        '\x2C5Bcad9Ade17428874855913Def0A02D8bE2324'
      )
    UNION
    SELECT
      "to" AS wallet,
      value AS value
    FROM
      erc20."ERC20_evt_Transfer"
    WHERE
      contract_address IN (
        '\x44017598f2AF1bD733F9D87b5017b4E7c1B28DDE',
        '\x45e007750Cc74B1D2b4DD7072230278d9602C499',
        '\x2C5Bcad9Ade17428874855913Def0A02D8bE2324'
      )
  ) c
  GROUP BY 1
) a
WHERE
  wallet NOT IN (
    '\x0000000000000000000000000000000000000000',
    '\x0000000000000000000000000000000000000001',
    '\x000000000000000000000000000000000000dead'
  )