/* Description: Calculate average and median age of wallets in days */
WITH
  age AS (
    SELECT
      wallet,
      MAX(age) AS age_days
    FROM
      (
        SELECT
          "to" AS wallet,
          (
            DATE_TRUNC('day', now()) - DATE_TRUNC('day', MIN(evt_block_time))
          ) as age
        FROM
          erc20."ERC20_evt_Transfer"
        WHERE
          "to" IN (
            '\x1Cf693eceEbEee99aD60e82973E2d4829C801335',
            '\x71c199C366625329064df3d08191CDC0e85AC2eA',
            '\xd61daEBC28274d1feaAf51F11179cd264e4105fB',
            '\xb7c60C8F27f6A944F923684606Fe3B5CE8998a2e',
            '\x60ecadC9fa4D4938f554954ec6DA578EBe191481',
            '\xC00fC2775cce5b61ffd6Ec1eEc0De0119f25DC87',
            '\x3bB3951A9F142d4d8ae3F83086E478152C8872d8',
            '\x24380d5a7c4239F2000fB4a6e07804a09597802e',
            '\x1d11e78148849200f3e937f31e8A9F66433E69f8'
          )
        GROUP BY
          1
        UNION
        SELECT
          "to" AS wallet,
          (
            DATE_TRUNC('day', now()) - DATE_TRUNC('day', MIN(evt_block_time))
          ) as age
        FROM
          erc721."ERC721_evt_Transfer"
        WHERE
          "to" IN (
            '\x1Cf693eceEbEee99aD60e82973E2d4829C801335',
            '\x71c199C366625329064df3d08191CDC0e85AC2eA',
            '\xd61daEBC28274d1feaAf51F11179cd264e4105fB',
            '\xb7c60C8F27f6A944F923684606Fe3B5CE8998a2e',
            '\x60ecadC9fa4D4938f554954ec6DA578EBe191481',
            '\xC00fC2775cce5b61ffd6Ec1eEc0De0119f25DC87',
            '\x3bB3951A9F142d4d8ae3F83086E478152C8872d8',
            '\x24380d5a7c4239F2000fB4a6e07804a09597802e',
            '\x1d11e78148849200f3e937f31e8A9F66433E69f8'
          )
        GROUP BY
          1
      ) age
    GROUP BY
      1
    ORDER BY
      2 DESC
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
  age