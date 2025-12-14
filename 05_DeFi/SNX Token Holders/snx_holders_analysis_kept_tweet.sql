/* Description: Calculate total wallets, ever held SNX, before 2nd May, and before bounty */

WITH 
  transfers AS (
    SELECT 
      day,
      address,
      token_address,
      SUM(amount) AS amount
    FROM (
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
        '\xDf5fa32B726a5118281e74aD3B7C707423e28F8B',
        '\x64Af258F8522Bb9dD2c2B648B9CBBCDbe986B0BF',
        '\xb6bbE5a785F6cfEd3F65F2BA91AD20586B00f7E6',
        '\x32ffC2374fA900FDe59D7B7388Bb4a9A9Dbe6123',
        '\xe3cf9bE65Fe3E9786E5E85f29f72499190FB3eE5',
        '\xB1E8897458e06bC542Af612ac440b9edFF4363B8',
        '\xB69e74324bc030F1B5409236EFA461496D439116',
        '\x61cE616a39F5735F844a3BC5D67Fe2ab8E64e702',
        '\x917b4B0E86fC7766695095dD1A5292B3BE8b2D14',
        '\xd61daEBC28274d1feaAf51F11179cd264e4105fB',
        '\x018439894b681cC2aAdDB613A425a1cfA6e59c29',
        '\xFF16d64179A02D6a56a1183A28f1D6293646E2dd',
        '\x2FFEd3158bB66a974E46E17E94b17e93202B804b',
        '\x862225a65786E198db423c686341913CaC8a5B3a',
        '\x5fa18F60c6e4a08493ABd3A4da7B02E20B0Cb2F9',
        '\x3e3672B23eB22946A31263d2D178bF0fB1f4BBFD',
        '\x976FdC5DfA145E3cbc690E9fef4a408642732952',
        '\x45740E393a093Cb341Eb0Cb8772605A6b7034A87',
        '\xAea790Ce88C2994390a97BfBE45b6743569a9020',
        '\x47d312c7604b1751f691011AeD4cE32231Bff4d1',
        '\x01985690D95d15aB17F26BBA1A466703EA4367B3',
        '\xC6563c29f364F7E661FE112A02caA987F87B956f',
        '\x5208C58fB7e4561453EEA7622430928b6F7cc2FC',
        '\x273061aA9B9dDdDcE5b7C2D1EB7237611d558d4F',
        '\x706D961Ab69d54a0FCbaa13E77842279A5724139',
        '\xC00fC2775cce5b61ffd6Ec1eEc0De0119f25DC87',
        '\x6936b10D58D9aC6292ABf1167C0D9eec64615D86',
        '\x2E63EE889BB210392CED9C03D3c0BdAf97E1CC08',
        '\xE14a13b8eB93B6569a748EA57A1A97025fc82BE9',
        '\x7796D7E2F04b2854cB32F52C6014bEe89fD93C18',
        '\xa1909f656e11086902c23Ce4BC2EE1B4950aDAeE',
        '\x7A60e93Df6Ed28C63D5E9283BD91b3C1dC3e613B',
        '\x9e89b2e39841a7c3b35a161E78b1d4ba198602CC',
        '\x2498F34bF4276E8b535717701Ab6b2D3c50310D5',
        '\x4beBBc16403627fD16facD2D9Be0Ba21aFad7fd8',
        '\x23b6d8e09CB33B1550DE19aC25cC3F41ae4603Bb',
        '\x11eBeE2bF244325B5559f0F583722d35659DDcE8'
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
        '\x64Af258F8522Bb9dD2c2B648B9CBBCDbe986B0BF',
        '\xb6bbE5a785F6cfEd3F65F2BA91AD20586B00f7E6',
        '\x32ffC2374fA900FDe59D7B7388Bb4a9A9Dbe6123',
        '\xe3cf9bE65Fe3E9786E5E85f29f72499190FB3eE5',
        '\xB1E8897458e06bC542Af612ac440b9edFF4363B8',
        '\xB69e74324bc030F1B5409236EFA461496D439116',
        '\x61cE616a39F5735F844a3BC5D67Fe2ab8E64e702',
        '\x917b4B0E86fC7766695095dD1A5292B3BE8b2D14',
        '\xd61daEBC28274d1feaAf51F11179cd264e4105fB',
        '\x018439894b681cC2aAdDB613A425a1cfA6e59c29',
        '\xFF16d64179A02D6a56a1183A28f1D6293646E2dd',
        '\x2FFEd3158bB66a974E46E17E94b17e93202B804b',
        '\x862225a65786E198db423c686341913CaC8a5B3a',
        '\x5fa18F60c6e4a08493ABd3A4da7B02E20B0Cb2F9',
        '\x3e3672B23eB22946A31263d2D178bF0fB1f4BBFD',
        '\x976FdC5DfA145E3cbc690E9fef4a408642732952',
        '\x45740E393a093Cb341Eb0Cb8772605A6b7034A87',
        '\xAea790Ce88C2994390a97BfBE45b6743569a9020',
        '\x47d312c7604b1751f691011AeD4cE32231Bff4d1',
        '\x01985690D95d15aB17F26BBA1A466703EA4367B3',
        '\xC6563c29f364F7E661FE112A02caA987F87B956f',
        '\x5208C58fB7e4561453EEA7622430928b6F7cc2FC',
        '\x273061aA9B9dDdDcE5b7C2D1EB7237611d558d4F',
        '\x706D961Ab69d54a0FCbaa13E77842279A5724139',
        '\xC00fC2775cce5b61ffd6Ec1eEc0De0119f25DC87',
        '\x6936b10D58D9aC6292ABf1167C0D9eec64615D86',
        '\x2E63EE889BB210392CED9C03D3c0BdAf97E1CC08',
        '\xE14a13b8eB93B6569a748EA57A1A97025fc82BE9',
        '\x7796D7E2F04b2854cB32F52C6014bEe89fD93C18',
        '\xa1909f656e11086902c23Ce4BC2EE1B4950aDAeE',
        '\x7A60e93Df6Ed28C63D5E9283BD91b3C1dC3e613B',
        '\x9e89b2e39841a7c3b35a161E78b1d4ba198602CC',
        '\x2498F34bF4276E8b535717701Ab6b2D3c50310D5',
        '\x4beBBc16403627fD16facD2D9Be0Ba21aFad7fd8',
        '\x23b6d8e09CB33B1550DE19aC25cC3F41ae4603Bb',
        '\x11eBeE2bF244325B5559f0F583722d35659DDcE8'
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
        '\x64Af258F8522Bb9dD2c2B648B9CBBCDbe986B0BF',
        '\xb6bbE5a785F6cfEd3F65F2BA91AD20586B00f7E6',
        '\x32ffC2374fA900FDe59D7B7388Bb4a9A9Dbe6123',
        '\xe3cf9bE65Fe3E9786E5E85f29f72499190FB3eE5',
        '\xB1E8897458e06bC542Af612ac440b9edFF4363B8',
        '\xB69e74324bc030F1B5409236EFA461496D439116',
        '\x61cE616a39F5735F844a3BC5D67Fe2ab8E64e702',
        '\x917b4B0E86fC7766695095dD1A5292B3BE8b2D14',
        '\xd61daEBC28274d1feaAf51F11179cd264e4105fB',
        '\x018439894b681cC2aAdDB613A425a1cfA6e59c29',
        '\xFF16d64179A02D6a56a1183A28f1D6293646E2dd',
        '\x2FFEd3158bB66a974E46E17E94b17e93202B804b',
        '\x862225a65786E198db423c686341913CaC8a5B3a',
        '\x5fa18F60c6e4a08493ABd3A4da7B02E20B0Cb2F9',
        '\x3e3672B23eB22946A31263d2D178bF0fB1f4BBFD',
        '\x976FdC5DfA145E3cbc690E9fef4a408642732952',
        '\x45740E393a093Cb341Eb0Cb8772605A6b7034A87',
        '\xAea790Ce88C2994390a97BfBE45b6743569a9020',
        '\x47d312c7604b1751f691011AeD4cE32231Bff4d1',
        '\x01985690D95d15aB17F26BBA1A466703EA4367B3',
        '\xC6563c29f364F7E661FE112A02caA987F87B956f',
        '\x5208C58fB7e4561453EEA7622430928b6F7cc2FC',
        '\x273061aA9B9dDdDcE5b7C2D1EB7237611d558d4F',
        '\x706D961Ab69d54a0FCbaa13E77842279A5724139',
        '\xC00fC2775cce5b61ffd6Ec1eEc0De0119f25DC87',
        '\x6936b10D58D9aC6292ABf1167C0D9eec64615D86',
        '\x2E63EE889BB210392CED9C03D3c0BdAf97E1CC08',
        '\xE14a13b8eB93B6569a748EA57A1A97025fc82BE9',
        '\x7796D7E2F04b2854cB32F52C6014bEe89fD93C18',
        '\xa1909f656e11086902c23Ce4BC2EE1B4950aDAeE',
        '\x7A60e93Df6Ed28C63D5E9283BD91b3C1dC3e613B',
        '\x9e89b2e39841a7c3b35a161E78b1d4ba198602CC',
        '\x2498F34bF4276E8b535717701Ab6b2D3c50310D5',
        '\x4beBBc16403627fD16facD2D9Be0Ba21aFad7fd8',
        '\x23b6d8e09CB33B1550DE19aC25cC3F41ae4603Bb',
        '\x11eBeE2bF244325B5559f0F583722d35659DDcE8'
      )
  ),
  total_wallets_analysis AS (
    SELECT 
      37 AS wallets
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
  before_bounty