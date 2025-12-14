/* Description: Calculate weekly growth in transactions for specified Solana addresses */
WITH txn_volume AS (
  SELECT 
    CASE 
      WHEN (block_time > NOW() - INTERVAL '1 WEEK') THEN '2' 
      ELSE '1'
    END AS datex,
    COUNT(DISTINCT tx_id) AS count_txns
  FROM `solana`.`account_activity`
  WHERE 
    (address = '675kPX9MHTjS2zt1qfr1NYHuzeLXfQM9H24wFSUt1Mp8'  -- Liquidity Pool AMM
     OR address = 'EhhTKczWMGQt46ynNeRX1WfeagwwJd7ufHvCDjRxjo5Q'  -- Staking
     OR address = 'routeUGWgWzqBWFcrCfv8tritsqukccJPu3q5GPP3xS'   -- AMM Routing
     OR address = '9KEPoZmtHUrBbhWN1v1KWLMkkvwY6WLtAVUCPRtRjP4z'  -- Farm Staking
     OR address = '9HzJyW1qZsEiSfMUf6L2jo3CcTKAyBmSyKdwQeYisHrC'   -- AcceleRaytor
    ) 
    AND block_time > NOW() - INTERVAL '2 WEEKS'
  GROUP BY 1
)
SELECT 
  datex,
  SUM(count_txns) AS count_txns,
  (SUM(count_txns) - LAG(SUM(count_txns), 1) OVER (ORDER BY datex)) / 
  LAG(SUM(count_txns), 1) OVER (ORDER BY datex) * 100 AS growth
FROM txn_volume
GROUP BY 1;