SELECT
  AVG(time_diff) AS avg_lock,
  PERCENTILE_CONT(0.5) WITHIN GROUP(
    ORDER BY
      time_diff
  ) AS median_lock
FROM
  (
    SELECT
      (
        DATE_PART('DAY', COALESCE(unlock_time, NOW()) - lock_time) * 24 + DATE_PART('HOUR', COALESCE(unlock_time, NOW()) - lock_time)
      ) / 24 AS time_diff,
      value
    FROM
      (
        SELECT
          lock_time,
          TIMESTAMP 'epoch' + cast(unlock_time as bigint) * INTERVAL '1 SECOND' AS unlock_time,
          value
        FROM
          (
            SELECT
              DISTINCT evt_block_time AS lock_time,
              bytea2numeric("topic3") AS unlock_time,
              t.value / 10 ^ 18 AS value
            FROM
              ethereum."logs" l
              LEFT JOIN erc20."ERC20_evt_Transfer" t ON t.evt_tx_hash = l.tx_hash
              AND t."to" = l.contract_address
            WHERE
              l.contract_address = '\xC5ca1EBF6e912E49A6a70Bb0385Ea065061a4F09'
              AND bytea2numeric("topic3") IS NOT NULL
          ) x
      ) y
  ) z