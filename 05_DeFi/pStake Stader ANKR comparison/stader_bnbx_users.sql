/* Description: Count active and total wallets based on balance. */

SELECT
  COUNT(DISTINCT 
    CASE 
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
      "_account" AS wallet,
      "_amount" / 1e18 AS value
    FROM 
      stader_labs."BnbX_call_mint"
    UNION
    SELECT 
      "_account" AS wallet,
      (-1) * "_amount" / 1e18 AS value
    FROM 
      stader_labs."BnbX_call_burn"
  ) x
  GROUP BY 1
) y