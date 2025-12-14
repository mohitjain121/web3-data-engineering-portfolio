/* Description: Calculate total wallets, ever held index, and held before bounty */

WITH 
  transfers AS (
    SELECT 
      day,
      address,
      token_address,
      sum(amount) AS amount
    FROM (
      SELECT 
        date_trunc('day', evt_block_time) AS day,
        "to" AS address,
        tr.contract_address AS token_address,
        value AS amount
      FROM 
        erc20."ERC20_evt_Transfer" tr
      WHERE 
        contract_address = '\x7C07F7aBe10CE8e33DC6C5aD68FE033085256A84'
      UNION ALL
      SELECT 
        date_trunc('day', evt_block_time) AS day,
        "from" AS address,
        tr.contract_address AS token_address,
        - value AS amount
      FROM 
        erc20."ERC20_evt_Transfer" tr
      WHERE 
        contract_address = '\x7C07F7aBe10CE8e33DC6C5aD68FE033085256A84'
    ) t
    GROUP BY 
      1,
      2,
      3
  ),
  balances_with_gap_days AS (
    SELECT 
      t.day,
      address,
      SUM(amount) OVER (
        PARTITION BY address
        ORDER BY 
          t.day
      ) AS balance,
      lead(day, 1, now()) OVER (
        PARTITION BY address
        ORDER BY 
          t.day
      ) AS next_day
    FROM 
      transfers t
  ),
  days AS (
    SELECT 
      generate_series(
        '2020-08-10'::timestamp,
        date_trunc('day', NOW()),
        '1 day'
      ) AS day
  ),
  balance_all_days AS (
    SELECT 
      d.day,
      address,
      SUM(balance / 10 ^ 0) AS balance
    FROM 
      balances_with_gap_days b
      INNER JOIN days d ON b.day <= d.day
      AND d.day < b.next_day
    GROUP BY 
      1,
      2
    ORDER BY 
      1,
      2
  ),
  ever_held AS (
    SELECT 
      COUNT(DISTINCT address) AS ever_held_index
    FROM 
      balance_all_days
    WHERE 
      day < '2022-05-18'
      AND address IN (
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
  ),
  before_bounty AS (
    SELECT 
      COUNT(DISTINCT address) AS held_before_bounty
    FROM 
      balance_all_days
    WHERE 
      balance > 0
      AND day = '2022-05-16'
      AND address IN (
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
  ),
  total_wallets_analysis AS (
    SELECT 
      50 AS wallets
  )
SELECT 
  wallets AS total_wallets,
  ever_held_index,
  held_before_bounty
FROM 
  total_wallets_analysis,
  ever_held,
  before_bounty