/* Description: Count active and total wallets, positions, and filter out specific wallet addresses */
SELECT
  COUNT(DISTINCT CASE WHEN wallet_balance > 0 THEN wallet ELSE NULL END) AS "active_wallets",
  COUNT(DISTINCT wallet) AS "total_wallets",
  SUM(CASE WHEN wallet_balance > 0 THEN 1 ELSE 0 END) AS "active_positions",
  COUNT(wallet) AS "total_positions"
FROM (
  SELECT 
    wallet, 
    tag, 
    SUM(value) AS wallet_balance, 
    symbol
  FROM (
    SELECT 
      t.contract_address, 
      y.symbol,
      y.tag,
      t.from AS wallet,
      (-1) * value / 10 ^ (y.decimals) AS value
    FROM 
      erc20.ERC20_evt_Transfer t
      INNER JOIN yearn.yearn_all_vaults y
      ON t.contract_address = y.contract_address
    UNION
    SELECT 
      t.contract_address, 
      y.symbol,
      y.tag,
      t.to AS wallet,
      value / 10 ^ (y.decimals) AS value
    FROM 
      erc20.ERC20_evt_Transfer t
      INNER JOIN yearn.yearn_all_vaults y
      ON t.contract_address = y.contract_address
  ) c
  GROUP BY 1, 2, 4
) a
WHERE wallet NOT IN (
  '\x0000000000000000000000000000000000000000',
  '\x0000000000000000000000000000000000000001',
  '\x000000000000000000000000000000000000dead'
)