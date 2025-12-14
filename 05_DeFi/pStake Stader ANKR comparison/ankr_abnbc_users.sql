/* Description: Count active and total wallets based on BEP20 transfer events. */

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
      "to" AS wallet,
      "value" / 1e18 AS value
    FROM
      bep20."BEP20_evt_Transfer"
    WHERE
      evt_tx_hash IN (
        SELECT
          DISTINCT call_tx_hash
        FROM
          ankr."aBNBc_call_mint"
        WHERE
          call_success = TRUE
      )
    UNION
    SELECT
      "from" AS wallet,
      (-1) * "value" / 1e18 AS value
    FROM
      bep20."BEP20_evt_Transfer"
    WHERE
      evt_tx_hash IN (
        SELECT
          DISTINCT call_tx_hash
        FROM
          ankr."aBNBc_call_burn"
        WHERE
          call_success = TRUE
      )
  ) x
  GROUP BY
    wallet
)
y