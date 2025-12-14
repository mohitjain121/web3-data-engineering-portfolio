WITH
  users AS (
    SELECT
      evt_block_time AS datex,
      "from" AS unique_users
    FROM
      erc20."ERC20_evt_Transfer"
    WHERE
      "to" = '\xf5ba2E5DdED276fc0f7a7637A61157a4be79C626'
    UNION
    SELECT
      evt_block_time AS datex,
      "to" AS unique_users
    FROM
      erc20."ERC20_evt_Transfer"
    WHERE
      "from" = '\xf5ba2E5DdED276fc0f7a7637A61157a4be79C626'
    UNION
    SELECT
      evt_block_time AS datex,
      "from" AS unique_users
    FROM
      erc20."ERC20_evt_Transfer"
    WHERE
      "to" IN (
        SELECT
          "_futureVault"
        FROM
          apwine."Controller_call_deposit"
      )
    UNION
    SELECT
      evt_block_time AS datex,
      "to" AS unique_users
    FROM
      erc20."ERC20_evt_Transfer"
    WHERE
      "from" IN (
        SELECT
          "_futureVault"
        FROM
          apwine."Controller_call_withdraw"
      )
  )
SELECT
  COUNT(
    DISTINCT CASE
      WHEN datex > NOW() - '24 HOURS':: INTERVAL THEN unique_users
    END
  ) AS "24_hour_users",
  COUNT(
    DISTINCT CASE
      WHEN datex > NOW() - '7 DAYS':: INTERVAL THEN unique_users
    END
  ) AS "7_days_users",
  COUNT(
    DISTINCT CASE
      WHEN datex > NOW() - '1 MONTH':: INTERVAL THEN unique_users
    END
  ) AS "1_month_users"
FROM
  users