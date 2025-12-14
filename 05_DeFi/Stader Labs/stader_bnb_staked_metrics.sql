/* Description: Calculate average and median BNB staked and calculate the percentage of BNB staked for each wallet. */

WITH
  bnb_staked AS (
    SELECT
      wallet,
      SUM(value) AS bnb_staked
    FROM
      (
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
    GROUP BY
      1
  ),
  holdings AS (
    SELECT
      wallet,
      SUM(amount) / 1e18 AS bnb_holdings
    FROM
      (
        SELECT
          t."from" AS wallet,
          -1 * t.value AS amount
        FROM
          bsc."traces" t
        WHERE
          t."from" IN (
            SELECT
              wallet
            FROM
              bnb_staked
          )
          AND t.success = TRUE AND t.value > 0
        UNION ALL
        SELECT
          t."to" AS wallet,
          t.value AS amount
        FROM
          bsc."traces" t
        WHERE
          t."to" IN (
            SELECT
              wallet
            FROM
              bnb_staked
          )
          AND t.success = TRUE AND t.value > 0
      ) x
    GROUP BY
      1
  )
SELECT
  AVG(bnb_staked) AS avg_bnb_staked,
  PERCENTILE_CONT(0.5) WITHIN GROUP (
    ORDER BY
      bnb_staked
  ) AS med_bnb_staked
FROM
  (
    SELECT
      h.wallet,
      bnb_holdings,
      bnb_staked,
      bnb_staked / (bnb_holdings + bnb_staked) :: FLOAT AS percent_staked
    FROM
      holdings h
      INNER JOIN bnb_staked b ON h.wallet = b.wallet
    WHERE
      bnb_holdings > 0
  ) x