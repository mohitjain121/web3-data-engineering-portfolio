/* Description: Calculate liquidity pool AMM transactions and wallets per date */
WITH 
lp_amm_txns AS 
(
  SELECT
    block_date AS datex,
    COUNT(DISTINCT tx_id) AS txns
  FROM `solana`.`account_activity`
  WHERE 
    address = '675kPX9MHTjS2zt1qfr1NYHuzeLXfQM9H24wFSUt1Mp8'  -- Liquidity Pool AMM
    AND block_date > NOW() - INTERVAL '1 MONTH'
    AND tx_success = TRUE
  GROUP BY 1
),
lp_amm_wallets AS 
(
  SELECT
    block_date AS datex,
    COUNT(DISTINCT account_keys[0]) AS wallets
  FROM solana.transactions 
  WHERE 
    array_contains(account_keys, '675kPX9MHTjS2zt1qfr1NYHuzeLXfQM9H24wFSUt1Mp8')
    AND block_date > NOW() - INTERVAL '1 MONTH'
    AND success = TRUE
  GROUP BY 1
)
SELECT 
  t.datex,
  t.txns,
  w.wallets,
  t.txns / w.wallets AS no_txn_per_wallet
FROM 
  lp_amm_txns t 
  LEFT JOIN 
  lp_amm_wallets w 
  ON w.datex = t.datex
GROUP BY 
  1, 2, 3;