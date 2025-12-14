/* Description: Calculate total wallets, ever held SNX, before 2nd May, and before bounty */

WITH 
  transfers AS (
    SELECT 
      day,
      address,
      token_address,
      SUM(amount) AS amount
    FROM 
      (
        SELECT 
          date_trunc('day', evt_block_time) AS day,
          "to" AS address,
          tr.contract_address AS token_address,
          value AS amount
        FROM 
          erc20."ERC20_evt_Transfer" tr
        WHERE 
          contract_address = '\x8700dAec35aF8Ff88c16BdF0418774CB3D7599B4'
        UNION ALL
        SELECT 
          date_trunc('day', evt_block_time) AS day,
          "from" AS address,
          tr.contract_address AS token_address,
          - value AS amount
        FROM 
          erc20."ERC20_evt_Transfer" tr
        WHERE 
          contract_address = '\x8700dAec35aF8Ff88c16BdF0418774CB3D7599B4'
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
      LEAD(day, 1, NOW()) OVER (
        PARTITION BY address
        ORDER BY 
          t.day
      ) AS next_day
    FROM 
      transfers t
  ),
  days AS (
    SELECT 
      GENERATE_SERIES(
        '2020-08-10':: TIMESTAMP,
        DATE_TRUNC('day', NOW()),
        '1 day'
      ) AS day
  ),
  balance_all_days AS (
    SELECT 
      d.day,
      address,
      SUM(balance / POWER(10, 0)) AS balance
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
      COUNT(DISTINCT address) AS ever_held_SNX
    FROM 
      balance_all_days
    WHERE 
      day < '2022-05-10'
      AND address IN (
        '\xDf5fa32B726a5118281e74aD3B7C707423e28F8B',
        '\xeC5c16f3EAF86a801a3E89201DD39bDDD1786cBF',
        '\x9Ec01d2A66Ac9A6173050383e1EFD93f5b883294',
        '\x10DbC99C90234E4447f0366e8368d688f622475A',
        '\x64Af258F8522Bb9dD2c2B648B9CBBCDbe986B0BF',
        '\xb6bbE5a785F6cfEd3F65F2BA91AD20586B00f7E6',
        '\xcF10A8E7c907144cc87721aC1fD7Ac75a8aebeC7',
        '\x32ffC2374fA900FDe59D7B7388Bb4a9A9Dbe6123'
      )
  ),
  before_bounty AS (
    SELECT 
      COUNT(DISTINCT address) AS held_before_bounty
    FROM 
      balance_all_days
    WHERE 
      balance > 0
      AND day = '2022-05-08'
      AND address IN (
        '\xDf5fa32B726a5118281e74aD3B7C707423e28F8B',
        '\xeC5c16f3EAF86a801a3E89201DD39bDDD1786cBF',
        '\x9Ec01d2A66Ac9A6173050383e1EFD93f5b883294',
        '\x10DbC99C90234E4447f0366e8368d688f622475A',
        '\x64Af258F8522Bb9dD2c2B648B9CBBCDbe986B0BF',
        '\xb6bbE5a785F6cfEd3F65F2BA91AD20586B00f7E6',
        '\xcF10A8E7c907144cc87721aC1fD7Ac75a8aebeC7',
        '\x32ffC2374fA900FDe59D7B7388Bb4a9A9Dbe6123'
      )
  ),
  before_2nd_may AS (
    SELECT 
      COUNT(DISTINCT address) AS before_2nd_may
    FROM 
      balance_all_days
    WHERE 
      balance > 0
      AND day = '2022-05-02'
      AND address IN (
        '\xDf5fa32B726a5118281e74aD3B7C707423e28F8B',
        '\xeC5c16f3EAF86a801a3E89201DD39bDDD1786cBF',
        '\x9Ec01d2A66Ac9A6173050383e1EFD93f5b883294',
        '\x10DbC99C90234E4447f0366e8368d688f622475A',
        '\x64Af258F8522Bb9dD2c2B648B9CBBCDbe986B0BF',
        '\xb6bbE5a785F6cfEd3F65F2BA91AD20586B00f7E6',
        '\xcF10A8E7c907144cc87721aC1fD7Ac75a8aebeC7',
        '\x32ffC2374fA900FDe59D7B7388Bb4a9A9Dbe6123'
      )
  ),
  total_wallets_analysis AS (
    SELECT 
      60 AS wallets
  )
SELECT 
  wallets AS total_wallets,
  ever_held_SNX,
  before_2nd_may,
  held_before_bounty
FROM 
  total_wallets_analysis,
  ever_held,
  before_2nd_may,
  before_bounty;