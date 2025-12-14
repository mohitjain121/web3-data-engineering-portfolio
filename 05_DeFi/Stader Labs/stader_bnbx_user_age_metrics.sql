/* Description: Calculate average and median age of BnbX holders */
WITH
  bnbx_holders AS (
    SELECT
      "_account" AS wallet
    FROM
      stader_labs."BnbX_call_mint"
  ),
  age AS (
    SELECT
      wallet,
      MAX(age) AS age_days
    FROM
      (
        SELECT
          "to" AS wallet,
          (
            DATE_TRUNC('day', now()) - DATE_TRUNC('day', MIN(block_time))
          ) AS age
        FROM
          bsc."transactions"
        WHERE
          "to" IN (
            SELECT
              wallet
            FROM
              bnbx_holders
          )
        GROUP BY
          1
        UNION
        SELECT
          "from" AS wallet,
          (
            DATE_TRUNC('day', now()) - DATE_TRUNC('day', MIN(block_time))
          ) AS age
        FROM
          bsc."transactions"
        WHERE
          "from" IN (
            SELECT
              wallet
            FROM
              bnbx_holders
          )
        GROUP BY
          1
      ) x
    GROUP BY
      1
  )
SELECT
  DATE_TRUNC('DAY', AVG(age_days)) AS avg_age,
  DATE_TRUNC(
    'DAY',
    PERCENTILE_CONT(0.5) WITHIN GROUP(
      ORDER BY
        age_days
    )
  ) AS med_age
FROM
  age;