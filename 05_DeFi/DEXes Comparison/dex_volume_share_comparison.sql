/* Description: Calculate project volumes over different time periods. */

WITH
  one_day_volume AS (
    SELECT
      project AS "project",
      SUM(usd_amount) AS usd_volume
    FROM
      dex."trades"
    WHERE
      block_time > NOW() - '24 hours':: INTERVAL
    GROUP BY
      1
  ),
  seven_day_volume AS (
    SELECT
      project AS "project",
      SUM(usd_amount) AS usd_volume
    FROM
      dex."trades"
    WHERE
      block_time > NOW() - '7 days':: INTERVAL
    GROUP BY
      1
  ),
  thirty_day_volume AS (
    SELECT
      project AS "project",
      SUM(usd_amount) AS usd_volume
    FROM
      dex."trades"
    WHERE
      block_time > NOW() - '30 days':: INTERVAL
    GROUP BY
      1
  )
SELECT
  ROW_NUMBER () OVER (
    ORDER BY
      SUM(thirty.usd_volume) DESC
  ) AS "rank",
  thirty."project",
  SUM(one.usd_volume) AS "24 hours volume",
  SUM(seven.usd_volume) AS "7 days volume",
  SUM(thirty.usd_volume) AS "30 days volume"
FROM
  thirty_day_volume thirty
  LEFT JOIN seven_day_volume seven ON thirty."project" = seven."project"
  LEFT JOIN one_day_volume one ON thirty."project" = one."project"
GROUP BY
  2
ORDER BY
  1 ASC;