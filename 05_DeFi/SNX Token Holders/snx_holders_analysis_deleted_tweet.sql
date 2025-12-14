/* Description: Calculate total wallets, ever held SNX, before 2nd May, and before bounty */

WITH 
  transfers AS (
    SELECT 
      day,
      address,
      token_address,
      sum(amount) AS amount
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
      1, 2, 3
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
        '2020-08-10':: timestamp,
        date_trunc('day', NOW()),
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
      1, 2
    ORDER BY 
      1, 2
  ),
  ever_held AS (
    SELECT 
      COUNT(DISTINCT address) AS ever_held_SNX
    FROM 
      balance_all_days
    WHERE 
      day < '2022-05-10'
      AND address IN (
        '\xeC5c16f3EAF86a801a3E89201DD39bDDD1786cBF',
        '\x9Ec01d2A66Ac9A6173050383e1EFD93f5b883294',
        '\x10DbC99C90234E4447f0366e8368d688f622475A',
        '\xcF10A8E7c907144cc87721aC1fD7Ac75a8aebeC7',
        '\x5B36002E5Ee1103A44246f67b067FD5509b97A9E',
        '\x4254966AeB7A6a3a5A60b05219Eb356B70F12Ccc',
        '\x64eCc4f8fF76E58d7C2245f34d32B039ebF42bDf',
        '\x324Fbd9536bf3d77d36137310fd4abe5130DfEA9',
        '\xD7625B5eb8c96128A901EF90FE0ED01C287d253B',
        '\x3d409b7CaC949135657A9eE5f59FfC27E0Bf5d6E',
        '\x3a031CD5d4e1AcF9e6897Ff87Da169Ea08DDf22C',
        '\xBA1b35Eb69052aEF4CE95abC0c38e0Ff67410aEf',
        '\x77a13bE3e954c4370aeFE93BB5634283DB5e3D87',
        '\x7Ebe10f8e493e848396839eC22d92001B82eA592',
        '\xd861415F6703ab50Ce101C7E6f6A80ada1FC2B1c',
        '\x46d3101e96dfe3F84A7EEA176AA3699107900a9c',
        '\x0161d1Cc10116bb2a073A0c293d5E4F1a97A00b6',
        '\x1Cf693eceEbEee99aD60e82973E2d4829C801335',
        '\x7e1FF06fc9adACa7383560F3d674C6b686AEf67e',
        '\x15F60D31A768f7f69AD39315cD49A76C6d7cDF0a',
        '\x9bE394Eb181fccb33e624FDfFE9EB0Dba830f4c5',
        '\x6960d1fA290F0a60896D23Fc3b533a9b0de03644',
        '\xF68D2BfCecd7895BBa05a7451Dd09A1749026454'
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
        '\xeC5c16f3EAF86a801a3E89201DD39bDDD1786cBF',
        '\x9Ec01d2A66Ac9A6173050383e1EFD93f5b883294',
        '\x10DbC99C90234E4447f0366e8368d688f622475A',
        '\xcF10A8E7c907144cc87721aC1fD7Ac75a8aebeC7',
        '\x5B36002E5Ee1103A44246f67b067FD5509b97A9E',
        '\x4254966AeB7A6a3a5A60b05219Eb356B70F12Ccc',
        '\x64eCc4f8fF76E58d7C2245f34d32B039ebF42bDf',
        '\x324Fbd9536bf3d77d36137310fd4abe5130DfEA9',
        '\xD7625B5eb8c96128A901EF90FE0ED01C287d253B',
        '\x3d409b7CaC949135657A9eE5f59FfC27E0Bf5d6E',
        '\x3a031CD5d4e1AcF9e6897Ff87Da169Ea08DDf22C',
        '\xBA1b35Eb69052aEF4CE95abC0c38e0Ff67410aEf',
        '\x77a13bE3e954c4370aeFE93BB5634283DB5e3D87',
        '\x7Ebe10f8e493e848396839eC22d92001B82eA592',
        '\xd861415F6703ab50Ce101C7E6f6A80ada1FC2B1c',
        '\x46d3101e96dfe3F84A7EEA176AA3699107900a9c',
        '\x0161d1Cc10116bb2a073A0c293d5E4F1a97A00b6',
        '\x1Cf693eceEbEee99aD60e82973E2d4829C801335',
        '\x7e1FF06fc9adACa7383560F3d674C6b686AEf67e',
        '\x15F60D31A768f7f69AD39315cD49A76C6d7cDF0a',
        '\x9bE394Eb181fccb33e624FDfFE9EB0Dba830f4c5',
        '\x6960d1fA290F0a60896D23Fc3b533a9b0de03644',
        '\xF68D2BfCecd7895BBa05a7451Dd09A1749026454'
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
        '\xeC5c16f3EAF86a801a3E89201DD39bDDD1786cBF',
        '\x9Ec01d2A66Ac9A6173050383e1EFD93f5b883294',
        '\x10DbC99C90234E4447f0366e8368d688f622475A',
        '\xcF10A8E7c907144cc87721aC1fD7Ac75a8aebeC7',
        '\x5B36002E5Ee1103A44246f67b067FD5509b97A9E',
        '\x4254966AeB7A6a3a5A60b05219Eb356B70F12Ccc',
        '\x64eCc4f8fF76E58d7C2245f34d32B039ebF42bDf',
        '\x324Fbd9536bf3d77d36137310fd4abe5130DfEA9',
        '\xD7625B5eb8c96128A901EF90FE0ED01C287d253B',
        '\x3d409b7CaC949135657A9eE5f59FfC27E0Bf5d6E',
        '\x3a031CD5d4e1AcF9e6897Ff87Da169Ea08DDf22C',
        '\xBA1b35Eb69052aEF4CE95abC0c38e0Ff67410aEf',
        '\x77a13bE3e954c4370aeFE93BB5634283DB5e3D87',
        '\x7Ebe10f8e493e848396839eC22d92001B82eA592',
        '\xd861415F6703ab50Ce101C7E6f6A80ada1FC2B1c',
        '\x46d3101e96dfe3F84A7EEA176AA3699107900a9c',
        '\x0161d1Cc10116bb2a073A0c293d5E4F1a97A00b6',
        '\x1Cf693eceEbEee99aD60e82973E2d4829C801335',
        '\x7e1FF06fc9adACa7383560F3d674C6b686AEf67e',
        '\x15F60D31A768f7f69AD39315cD49A76C6d7cDF0a',
        '\x9bE394Eb181fccb33e624FDfFE9EB0Dba830f4c5',
        '\x6960d1fA290F0a60896D23Fc3b533a9b0de03644',
        '\xF68D2BfCecd7895BBa05a7451Dd09A1749026454'
      )
  ),
  total_wallets_analysis AS (
    SELECT 
      23 AS wallets
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