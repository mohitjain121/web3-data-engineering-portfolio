/* Description: Count active and total wallets based on wallet balances. */

SELECT
  COUNT(
    DISTINCT CASE
      WHEN wallet_balance > 0 THEN wallet
    END
  ) AS "active_wallets",
  COUNT(DISTINCT wallet) AS "total_wallets"
FROM (
  SELECT
    "to" AS wallet,
    SUM(
      CASE
        WHEN "from" = '\x0000000000000000000000000000000000000000' THEN value / 1e18
        WHEN "to" = '\x0000000000000000000000000000000000000000' THEN (-1) * value / 1e18
      END
    ) AS wallet_balance
  FROM
    bep20."BEP20_evt_Transfer"
  WHERE
    "from" IN (
      SELECT
        "to"
      FROM
        bep20."BEP20_evt_Transfer"
      WHERE
        contract_address = '\xd23ef71883a98c55Eb7ED67ED61fABF554aDEd21'
    )
    AND contract_address = '\xd23ef71883a98c55Eb7ED67ED61fABF554aDEd21'
  GROUP BY
    "to"
) x
WHERE
  "wallet" NOT IN ('\x03c509fd85d51dc7e75fa2de06276cfa147486ea', '\x0000000000000000000000000000000000000000')