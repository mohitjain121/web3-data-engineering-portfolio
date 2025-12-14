SELECT
  COUNT(
    DISTINCT CASE
      WHEN wallet_balance > 0 THEN wallet
      ELSE NULL
    END
  ) AS "Active Wallets",
  COUNT(DISTINCT wallet) AS "Total Wallets",
  SUM(
    CASE
      WHEN wallet_balance > 0 THEN 1
      ELSE 0
    END
  ) AS "Active Positions",
  COUNT(wallet) AS "Total Positions"
FROM
  (
    SELECT
      wallet,
      SUM(value) as wallet_balance,
      vault
    FROM
      (
        SELECT
          t."to" AS wallet,
          "_futureVault" AS vault,
          (1) * d."_amount" AS value
        FROM
          apwine."Controller_call_deposit" d
          LEFT JOIN erc20."ERC20_evt_Transfer" t ON t.evt_tx_hash = d.call_tx_hash
        WHERE
          call_success = 'true'
        UNION
        SELECT
          t."from" AS wallet,
          "_futureVault" AS vault,
          (-1) * w."_amount" AS value
        FROM
          apwine."Controller_call_withdraw" w
          LEFT JOIN erc20."ERC20_evt_Transfer" t ON t.evt_tx_hash = w.call_tx_hash
        WHERE
          call_success = 'true'
      ) x
    GROUP BY
      1,
      3
  ) z