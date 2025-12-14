/* Description: Count active and total wallets based on wallet balance. */

SELECT
  COUNT(DISTINCT CASE WHEN wallet_balance > 0 THEN wallet ELSE NULL END) AS "active_wallets",
  COUNT(DISTINCT wallet) AS "total_wallets"
FROM (
  SELECT 
    wallet, 
    SUM(value) AS wallet_balance
  FROM (
    SELECT 
      "from" AS wallet,
      (-1) * value AS value
    FROM bep20."BEP20_evt_Transfer"
    WHERE contract_address IN (
      '\xc2E9d07F66A89c44062459A47a0D2Dc038E4fb16' -- BNB
    )
    AND "to" = '\x0000000000000000000000000000000000000000'
    UNION
    SELECT 
      "to" AS wallet,
      value AS value
    FROM bep20."BEP20_evt_Transfer"
    WHERE contract_address IN (
      '\xc2E9d07F66A89c44062459A47a0D2Dc038E4fb16' -- BNB
    )
    AND "from" = '\x0000000000000000000000000000000000000000'
  ) c
  GROUP BY 1
) a
WHERE wallet NOT IN (
  '\x0000000000000000000000000000000000000000',
  '\x0000000000000000000000000000000000000001',
  '\x000000000000000000000000000000000000dead'
)