/* Description: Calculate average and median BNB staked and calculate the percentage of BNB staked for each wallet. */

WITH
  bnb_staked AS (
    SELECT
      wallet,
      SUM(value) AS bnb_staked
    FROM
      (
        SELECT
          "to" AS wallet,
          value / 1e18 AS value
        FROM
          bep20."BEP20_evt_Transfer"
        WHERE
          "contract_address" = '\xc2E9d07F66A89c44062459A47a0D2Dc038E4fb16'
          AND "from" = '\x0000000000000000000000000000000000000000'
        UNION
        SELECT
          "from" AS wallet,
          (-1) * value / 1e18 AS value
        FROM
          bep20."BEP20_evt_Transfer"
        WHERE
          "contract_address" = '\xc2E9d07F66A89c44062459A47a0D2Dc038E4fb16'
          AND "to" = '\x0000000000000000000000000000000000000000'
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
          AND t.success = true
          AND t.value > 0
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
          AND t.success = true
          AND t.value > 0
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