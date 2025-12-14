WITH
  ve_txns AS (
    SELECT
      date_trunc('DAY', evt_block_time) AS datex,
      COUNT(DISTINCT evt_tx_hash) AS ve_txns
    FROM
      erc20."ERC20_evt_Transfer"
    WHERE
      "to" = '\xC5ca1EBF6e912E49A6a70Bb0385Ea065061a4F09'
      OR "from" = '\xC5ca1EBF6e912E49A6a70Bb0385Ea065061a4F09'
    GROUP BY
      1
  ),
  swaps AS (
    SELECT
      date_trunc('DAY', evt_block_time) AS datex,
      COUNT(DISTINCT evt_tx_hash) AS swaps
    FROM
      erc20."ERC20_evt_Transfer"
    WHERE
      "to" = '\xf5ba2E5DdED276fc0f7a7637A61157a4be79C626'
      OR "from" = '\xf5ba2E5DdED276fc0f7a7637A61157a4be79C626'
    GROUP BY
      1
  ),
  deposit_txns AS (
    SELECT
      date_trunc('DAY', call_block_time) AS datex,
      COUNT(DISTINCT call_tx_hash) AS deposit_txns
    FROM
      apwine."Controller_call_deposit"
    WHERE
      call_success = 'true'
    GROUP BY
      1
  ),
  withdraw_txns AS (
    SELECT
      date_trunc('DAY', call_block_time) AS datex,
      COUNT(DISTINCT call_tx_hash) AS withdraw_txns
    FROM
      apwine."Controller_call_withdraw"
    WHERE
      call_success = 'true'
    GROUP BY
      1
  )
SELECT
  -- CASE
  --     WHEN d.datex IS NOT NULL THEN d.datex
  --     ELSE WHEN w.datex IS NOT NULL THEN w.datex
  --     ELSE s.datex END AS datex,
  COALESCE(d.datex, w.datex, s.datex, v.datex) AS datex,
  COALESCE(deposit_txns, 0) + COALESCE(withdraw_txns, 0) + COALESCE(swaps, 0) + COALESCE(ve_txns, 0) AS total_txns,
  COALESCE(deposit_txns, 0) AS deposit_txns,
  COALESCE(withdraw_txns, 0) AS withdraw_txns,
  COALESCE(swaps, 0) AS swaps,
  COALESCE(ve_txns, 0) AS ve_txns
FROM
  deposit_txns d
  FULL JOIN withdraw_txns w ON d.datex = w.datex
  FULL JOIN swaps s ON s.datex = d.datex
  FULL JOIN ve_txns v ON v.datex = d.datex
ORDER BY
  1 DESC