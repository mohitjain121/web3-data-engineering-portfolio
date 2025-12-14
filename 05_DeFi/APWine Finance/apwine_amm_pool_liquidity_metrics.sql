WITH
  decimals AS (
    SELECT
      'SDT-StakeDAO' AS vault_name,
      '\xEd1CAC496E38b42efB73125Df30B1CEe8e4626E0':: BYTEA AS pt,
      '\x081A0599ceaCCc18B985D8cc0b04A6324ca7b97B':: BYTEA AS fyt,
      '\x73968b9a57c6E53d41345FD57a6E6ae27d6CDB2F':: BYTEA AS underlying,
      '\xc68B6987075944f9E8b0a6c2b52e923BC1fb9028':: BYTEA AS amm,
      18 AS decimals
    UNION
    SELECT
      'USDC-TrueFi' AS vault_name,
      '\x2B8692963C8eC4cdF30047a20F12C43E4d9aEf6C':: BYTEA AS pt,
      '\x94b52A2751D3A0Ca58251b07D6c7ced82180D03B':: BYTEA AS fyt,
      '\xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48':: BYTEA AS underlying,
      '\x0CC36e3cc5eACA6d046b537703ae946874d57299':: BYTEA AS amm,
      6 AS decimals
    UNION
    SELECT
      'StkAAVE-Paladin' AS vault_name,
      '\x018d9Fc19821222B4dd92E1c65C95D55192E49f0':: BYTEA AS pt,
      '\x9733B3604c47CE9d40D515F40a1DdabbDa5dC71d':: BYTEA AS fyt,
      '\x4da27a545c0c5B758a6BA100e3a049001de870f5':: BYTEA AS underlying,
      '\xc61C0F4961F2093A083f47a4b783ad260DeAF7eA':: BYTEA AS amm,
      18 AS decimals
    UNION
    SELECT
      'frax3crv-IDLE' AS vault_name,
      '\x4c0118C4682fe68e04c1d71d6168d05762Ff417d':: BYTEA AS pt,
      '\x5EA838Fe7407E71728779a45D49E9Dd848623614':: BYTEA AS fyt,
      '\x4CCaf1392a17203eDAb55a1F2aF3079A8Ac513E7':: BYTEA AS underlying,
      '\xeA851503Ff416E34585d28C248918344C569B219':: BYTEA AS amm,
      18 AS decimals
    UNION
    SELECT
      'PSP4-Paraswap' AS vault_name,
      '\x90e638C6039df98DbaF21b4dfB0C7D35c3c3Fe3E':: BYTEA AS pt,
      '\xB39F409A8F4407Cbd78296C8647b00c0d9052D92':: BYTEA AS fyt,
      '\xcAfE001067cDEF266AfB7Eb5A286dCFD277f3dE5':: BYTEA AS underlying,
      '\xA4085c106c7a9A7AD0574865bbd7CaC5E1098195':: BYTEA AS amm,
      18 AS decimals
    UNION
    SELECT
      'PSP3-Paraswap' AS vault_name,
      '\xEeB7F670Bf2C092bb4196217b215BA5B4499f71c':: BYTEA AS pt,
      '\x34917Aa2590D1DDEDE27b230A03D6f2E9b9bAd1D':: BYTEA AS fyt,
      '\xcAfE001067cDEF266AfB7Eb5A286dCFD277f3dE5':: BYTEA AS underlying,
      '\x49CbBFEDB15B5C22cac53Daf104512a5DE9C8457':: BYTEA AS amm,
      18 AS decimals
    UNION
    SELECT
      'frax-StakeDAO' AS vault_name,
      '\xAf5335a9A014C48F49623aB6aE7461B63a91aD9d':: BYTEA AS pt,
      '\x97e618CD39b6d94bDfD95Dc35d3DB6b94A84efd6':: BYTEA AS fyt,
      '\xd632f22692FaC7611d2AA1C0D552930D43CAEd3B':: BYTEA AS underlying,
      '\x839Bb033738510AA6B4f78Af20f066bdC824B189':: BYTEA AS amm,
      18 AS decimals
    UNION
    SELECT
      'Sushi-Sushi' AS vault_name,
      '\x3Cdf203a1Dd04271de460034c1ccA5e20477bB19':: BYTEA AS pt,
      '\x2cA72A8D436DFb42182E8694E8b93D550b9Ee230':: BYTEA AS fyt,
      '\x6B3595068778DD592e39A122f4f5a5cF09C90fE2':: BYTEA AS underlying,
      '\xcbA960001307A16ce8A9E326D73e92D53b446E81':: BYTEA AS amm,
      18 AS decimals
    UNION
    SELECT
      'OHM-Olympus' AS vault_name,
      '\x68b5515079FaFE7a41b636cd3B67a795dcD628c6':: BYTEA AS pt,
      '\x38F221a229864f8761A291Fe93e53A46f8Ba425E':: BYTEA AS fyt,
      '\x64aa3364f17a4d01c6f1751fd97c2bd3d7e7f1d5':: BYTEA AS underlying,
      '\x1089f7bbF8c680Db92759A30d42ddFbA7C794BD2':: BYTEA AS amm,
      18 AS decimals
    UNION
    SELECT
      'ibEUR-Yearn' AS vault_name,
      '\xA19862324Ef3c9E675d32d72868bfDDa147a5958':: BYTEA AS pt,
      '\x77B12Aa6cAB380d46CfC647471BA8ed9b4Fe9F86':: BYTEA AS fyt,
      '\x19b080FE1ffA0553469D20Ca36219F17Fcf03859':: BYTEA AS underlying,
      '\xbC35b70ccc8Ef4Ec1ccc34FaB60CcBBa162011e4':: BYTEA AS amm,
      18 AS decimals
    UNION
    SELECT
      'FARM-Harvest' AS vault_name,
      '\xa192a2381f9a2695adD598A32da0C35a7F92E919':: BYTEA AS pt,
      '\x27d5A02805eE97CAD27c7f9Fcf93e404e9c87513':: BYTEA AS fyt,
      '\xa0246c9032bC3A600820415aE600c6388619A14D':: BYTEA AS underlying,
      '\x4Df9Bb881E5e61034001440AaaFf2FB2932E2883':: BYTEA AS amm,
      18 AS decimals
    UNION
    SELECT
      'c3Crypto-Yearn' AS vault_name,
      '\xCda6bC3f0c60b2ea2Ca836319225f7848AFc40b8':: BYTEA AS pt,
      '\xaB65B556bF21c0155b6C480595C71D8674287b16':: BYTEA AS fyt,
      '\xcA3d75aC011BF5aD07a98d02f18225F9bD9A6BDF':: BYTEA AS underlying,
      '\x7259114Df363De5d42FDf00b705FAD7C85f8f795':: BYTEA AS amm,
      18 AS decimals
    UNION
    SELECT
      'ib3Crv-Yearn' AS vault_name,
      '\x2B63eD6A73C01ADC79A4f5D39BCBF0E36d47f448':: BYTEA AS pt,
      '\x1CBDF47FB9c11c484B96C4a857902817512599Bb':: BYTEA AS fyt,
      '\x5282a4eF67D9C33135340fB3289cc1711c13638C':: BYTEA AS underlying,
      '\x1a6525E4a4aB2E3aEa7ED3CF813e8ed07fA3446D':: BYTEA AS amm,
      18 AS decimals
    UNION
    SELECT
      'wETH-Lido' AS vault_name,
      '\x137189D1342AaBE7Cd75B42B265E4647596aaa01':: BYTEA AS pt,
      '\x955CB206FbD81AD040D6f4B76145605937D6E309':: BYTEA AS fyt,
      '\xc02aaa39b223fe8d0a0e5c4f27ead9083c756cc2':: BYTEA AS underlying,
      '\x1604C5e9aB488D66E983644355511DCEF5c32EDF':: BYTEA AS amm,
      18 AS decimals
    UNION
    SELECT
      'USDT-AAVE' AS vault_name,
      '\x2d31591f7a650579125bC9BC1622E07fFD219033':: BYTEA AS pt,
      '\xF3a1031a3544d762a5fC3f3230103B8572809B53':: BYTEA AS fyt,
      '\x3Ed3B47Dd13EC9a98b44e6204A523E766B225811':: BYTEA AS underlying,
      '\xb932c4801240753604c768c991eb640BCD7C06EB':: BYTEA AS amm,
      6 AS decimals
  ),
  asset_change_underlying AS (
    SELECT
      datex,
      contract_address,
      vault_name,
      amm,
      SUM(value) AS underlying_change
    FROM
      (
        SELECT
          date_trunc('DAY', evt_block_time) AS datex,
          contract_address,
          vault_name,
          amm,
          (-1) * value / 10 ^ (
            CASE
              WHEN contract_address = '\x64aa3364f17a4d01c6f1751fd97c2bd3d7e7f1d5' THEN 9
              ELSE decimals
            END
          ) AS value
        FROM
          erc20."ERC20_evt_Transfer" t
          LEFT JOIN decimals d ON t.contract_address = d.underlying
        WHERE
          "contract_address" IN (
            '\x73968b9a57c6E53d41345FD57a6E6ae27d6CDB2F',
            '\xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48',
            '\x4da27a545c0c5B758a6BA100e3a049001de870f5',
            '\x4CCaf1392a17203eDAb55a1F2aF3079A8Ac513E7',
            -- '\xcAfE001067cDEF266AfB7Eb5A286dCFD277f3dE5',
            '\xd632f22692FaC7611d2AA1C0D552930D43CAEd3B',
            '\x6B3595068778DD592e39A122f4f5a5cF09C90fE2',
            '\x64aa3364f17a4d01c6f1751fd97c2bd3d7e7f1d5',
            '\x19b080FE1ffA0553469D20Ca36219F17Fcf03859',
            '\xa0246c9032bC3A600820415aE600c6388619A14D',
            '\xcA3d75aC011BF5aD07a98d02f18225F9bD9A6BDF',
            '\x5282a4eF67D9C33135340fB3289cc1711c13638C',
            '\xc02aaa39b223fe8d0a0e5c4f27ead9083c756cc2',
            '\x3Ed3B47Dd13EC9a98b44e6204A523E766B225811'
          )
          AND "from" IN (
            '\x7259114Df363De5d42FDf00b705FAD7C85f8f795',
            '\x0CC36e3cc5eACA6d046b537703ae946874d57299',
            '\x1604C5e9aB488D66E983644355511DCEF5c32EDF',
            '\xcbA960001307A16ce8A9E326D73e92D53b446E81',
            '\xb932c4801240753604c768c991eb640BCD7C06EB',
            '\xc61C0F4961F2093A083f47a4b783ad260DeAF7eA',
            '\xbC35b70ccc8Ef4Ec1ccc34FaB60CcBBa162011e4',
            '\x4Df9Bb881E5e61034001440AaaFf2FB2932E2883',
            '\x8A362AA1c81ED0Ee2Ae677A8b59e0f563DD290Ba',
            -- '\xA4085c106c7a9A7AD0574865bbd7CaC5E1098195', --PSP4
            -- '\x49cbbfedb15b5c22cac53daf104512a5de9c8457', --PSP3
            '\x839Bb033738510AA6B4f78Af20f066bdC824B189',
            '\x1089f7bbF8c680Db92759A30d42ddFbA7C794BD2',
            '\xeA851503Ff416E34585d28C248918344C569B219',
            '\x1a6525E4a4aB2E3aEa7ED3CF813e8ed07fA3446D'
          )
          
        UNION --PSP4start
        
        SELECT
            datex,
            contract_address,
            vault_name,
            amm,
            value
        FROM
        (SELECT
          date_trunc('DAY', evt_block_time) AS datex,
          '\xcAfE001067cDEF266AfB7Eb5A286dCFD277f3dE5'::BYTEA AS contract_address,
          'PSP4-Paraswap'::TEXT AS vault_name,
          '\xa4085c106c7a9a7ad0574865bbd7cac5e1098195'::BYTEA AS amm,
          (-1) * value / 10 ^ 18 AS value
        FROM
          erc20."ERC20_evt_Transfer"
        WHERE
          "contract_address" = '\xcAfE001067cDEF266AfB7Eb5A286dCFD277f3dE5'
          AND "from" = '\xa4085c106c7a9a7ad0574865bbd7cac5e1098195'
          AND "from" != '\x49cbbfedb15b5c22cac53daf104512a5de9c8457'
        UNION
        SELECT
          date_trunc('DAY', evt_block_time) AS datex,
          '\xcAfE001067cDEF266AfB7Eb5A286dCFD277f3dE5'::BYTEA AS contract_address,
          'PSP4-Paraswap'::TEXT AS vault_name,
          '\xa4085c106c7a9a7ad0574865bbd7cac5e1098195'::BYTEA AS amm,
          value / 10 ^ 18 AS value
        FROM
          erc20."ERC20_evt_Transfer" t
          LEFT JOIN decimals d ON t.contract_address = d.underlying
        WHERE
          "contract_address" = '\xcAfE001067cDEF266AfB7Eb5A286dCFD277f3dE5'
          AND "to" = '\xa4085c106c7a9a7ad0574865bbd7cac5e1098195'
          AND "to" != '\x49cbbfedb15b5c22cac53daf104512a5de9c8457') x
          WHERE amm  != '\x49cbbfedb15b5c22cac53daf104512a5de9c8457'
          
        UNION --PSP4end, PSP3start
        SELECT
            datex,
            contract_address,
            vault_name,
            amm,
            value
        FROM
        (SELECT
          date_trunc('DAY', evt_block_time) AS datex,
          '\xcAfE001067cDEF266AfB7Eb5A286dCFD277f3dE5'::BYTEA AS contract_address,
          'PSP3-Paraswap'::TEXT AS vault_name,
          '\x49cbbfedb15b5c22cac53daf104512a5de9c8457'::BYTEA AS amm,
          (-1) * value / 10 ^ 18 AS value
        FROM
          erc20."ERC20_evt_Transfer"
        WHERE
          "contract_address" = '\xcAfE001067cDEF266AfB7Eb5A286dCFD277f3dE5'
          AND "from" = '\x49cbbfedb15b5c22cac53daf104512a5de9c8457'
          AND "from" != '\xa4085c106c7a9a7ad0574865bbd7cac5e1098195'
        UNION
        SELECT
          date_trunc('DAY', evt_block_time) AS datex,
          '\xcAfE001067cDEF266AfB7Eb5A286dCFD277f3dE5'::BYTEA AS contract_address,
          'PSP3-Paraswap'::TEXT AS vault_name,
          '\x49cbbfedb15b5c22cac53daf104512a5de9c8457'::BYTEA AS amm,
          value / 10 ^ 18 AS value
        FROM
          erc20."ERC20_evt_Transfer"
        WHERE
          "contract_address" = '\xcAfE001067cDEF266AfB7Eb5A286dCFD277f3dE5'
          AND "to" = '\x49cbbfedb15b5c22cac53daf104512a5de9c8457'
          AND "to" != '\xa4085c106c7a9a7ad0574865bbd7cac5e1098195') x 
          WHERE amm  != '\xa4085c106c7a9a7ad0574865bbd7cac5e1098195'
          
        UNION --PSP3end
        
        SELECT
          date_trunc('DAY', evt_block_time) AS datex,
          contract_address,
          vault_name,
          amm,
          value / 10 ^ (
            CASE
              WHEN contract_address = '\x64aa3364f17a4d01c6f1751fd97c2bd3d7e7f1d5' THEN 9
              ELSE decimals
            END
          ) AS value
        FROM
          erc20."ERC20_evt_Transfer" t
          LEFT JOIN decimals d ON t.contract_address = d.underlying
        WHERE
          "contract_address" IN (
            '\x73968b9a57c6E53d41345FD57a6E6ae27d6CDB2F',
            '\xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48',
            '\x4da27a545c0c5B758a6BA100e3a049001de870f5',
            '\x4CCaf1392a17203eDAb55a1F2aF3079A8Ac513E7',
            -- '\xcAfE001067cDEF266AfB7Eb5A286dCFD277f3dE5',
            '\xd632f22692FaC7611d2AA1C0D552930D43CAEd3B',
            '\x6B3595068778DD592e39A122f4f5a5cF09C90fE2',
            '\x64aa3364f17a4d01c6f1751fd97c2bd3d7e7f1d5',
            '\x19b080FE1ffA0553469D20Ca36219F17Fcf03859',
            '\xa0246c9032bC3A600820415aE600c6388619A14D',
            '\xcA3d75aC011BF5aD07a98d02f18225F9bD9A6BDF',
            '\x5282a4eF67D9C33135340fB3289cc1711c13638C',
            '\xc02aaa39b223fe8d0a0e5c4f27ead9083c756cc2',
            '\x3Ed3B47Dd13EC9a98b44e6204A523E766B225811'
          )
          AND "to" IN (
            '\x7259114Df363De5d42FDf00b705FAD7C85f8f795',
            '\x0CC36e3cc5eACA6d046b537703ae946874d57299',
            '\x1604C5e9aB488D66E983644355511DCEF5c32EDF',
            '\xcbA960001307A16ce8A9E326D73e92D53b446E81',
            '\xb932c4801240753604c768c991eb640BCD7C06EB',
            '\xc61C0F4961F2093A083f47a4b783ad260DeAF7eA',
            '\xbC35b70ccc8Ef4Ec1ccc34FaB60CcBBa162011e4',
            '\x4Df9Bb881E5e61034001440AaaFf2FB2932E2883',
            '\x8A362AA1c81ED0Ee2Ae677A8b59e0f563DD290Ba',
            -- '\xA4085c106c7a9A7AD0574865bbd7CaC5E1098195', --PSP4
            -- '\x49cbbfedb15b5c22cac53daf104512a5de9c8457', --PSP3
            '\x839Bb033738510AA6B4f78Af20f066bdC824B189',
            '\x1089f7bbF8c680Db92759A30d42ddFbA7C794BD2',
            '\xeA851503Ff416E34585d28C248918344C569B219',
            '\x1a6525E4a4aB2E3aEa7ED3CF813e8ed07fA3446D'
          )
      ) x
    GROUP BY
      1,
      2,
      3,
      4
  ),
  asset_change_fyt AS (
    SELECT
      datex,
      contract_address,
      vault_name,
      amm,
      SUM(value) AS fyt_change
    FROM
      (
        SELECT
          date_trunc('DAY', evt_block_time) AS datex,
          contract_address,
          vault_name,
          amm,
          (-1) * value / 10 ^ (decimals) AS value
        FROM
          erc20."ERC20_evt_Transfer" t
          LEFT JOIN decimals d ON t.contract_address = d.fyt
        WHERE
          "contract_address" IN (
            '\x081A0599ceaCCc18B985D8cc0b04A6324ca7b97B',
            '\x94b52A2751D3A0Ca58251b07D6c7ced82180D03B',
            '\x9733B3604c47CE9d40D515F40a1DdabbDa5dC71d',
            '\x5EA838Fe7407E71728779a45D49E9Dd848623614',
            '\xB39F409A8F4407Cbd78296C8647b00c0d9052D92',
            '\x34917Aa2590D1DDEDE27b230A03D6f2E9b9bAd1D',
            '\x97e618CD39b6d94bDfD95Dc35d3DB6b94A84efd6',
            '\x2cA72A8D436DFb42182E8694E8b93D550b9Ee230',
            '\x77B12Aa6cAB380d46CfC647471BA8ed9b4Fe9F86',
            '\x27d5A02805eE97CAD27c7f9Fcf93e404e9c87513',
            '\xaB65B556bF21c0155b6C480595C71D8674287b16',
            '\x1CBDF47FB9c11c484B96C4a857902817512599Bb',
            '\x955CB206FbD81AD040D6f4B76145605937D6E309',
            '\xF3a1031a3544d762a5fC3f3230103B8572809B53',
            '\x38F221a229864f8761A291Fe93e53A46f8Ba425E'
          )
          AND "from" IN (
            '\x7259114Df363De5d42FDf00b705FAD7C85f8f795',
            '\x0CC36e3cc5eACA6d046b537703ae946874d57299',
            '\x1604C5e9aB488D66E983644355511DCEF5c32EDF',
            '\xcbA960001307A16ce8A9E326D73e92D53b446E81',
            '\xb932c4801240753604c768c991eb640BCD7C06EB',
            '\xc61C0F4961F2093A083f47a4b783ad260DeAF7eA',
            '\xbC35b70ccc8Ef4Ec1ccc34FaB60CcBBa162011e4',
            '\x4Df9Bb881E5e61034001440AaaFf2FB2932E2883',
            '\x8A362AA1c81ED0Ee2Ae677A8b59e0f563DD290Ba',
            '\xA4085c106c7a9A7AD0574865bbd7CaC5E1098195',
            '\x839Bb033738510AA6B4f78Af20f066bdC824B189',
            '\x1089f7bbF8c680Db92759A30d42ddFbA7C794BD2',
            '\xeA851503Ff416E34585d28C248918344C569B219',
            '\x49CbBFEDB15B5C22cac53Daf104512a5DE9C8457',
            '\x1a6525E4a4aB2E3aEa7ED3CF813e8ed07fA3446D'
          )
        UNION
        SELECT
          date_trunc('DAY', evt_block_time) AS datex,
          contract_address,
          vault_name,
          amm,
          value / 10 ^ (decimals) AS value
        FROM
          erc20."ERC20_evt_Transfer" t
          LEFT JOIN decimals d ON t.contract_address = d.fyt
        WHERE
          "contract_address" IN (
            '\x081A0599ceaCCc18B985D8cc0b04A6324ca7b97B',
            '\x94b52A2751D3A0Ca58251b07D6c7ced82180D03B',
            '\x9733B3604c47CE9d40D515F40a1DdabbDa5dC71d',
            '\x5EA838Fe7407E71728779a45D49E9Dd848623614',
            '\xB39F409A8F4407Cbd78296C8647b00c0d9052D92',
            '\x34917Aa2590D1DDEDE27b230A03D6f2E9b9bAd1D',
            '\x97e618CD39b6d94bDfD95Dc35d3DB6b94A84efd6',
            '\x2cA72A8D436DFb42182E8694E8b93D550b9Ee230',
            '\x77B12Aa6cAB380d46CfC647471BA8ed9b4Fe9F86',
            '\x27d5A02805eE97CAD27c7f9Fcf93e404e9c87513',
            '\xaB65B556bF21c0155b6C480595C71D8674287b16',
            '\x1CBDF47FB9c11c484B96C4a857902817512599Bb',
            '\x955CB206FbD81AD040D6f4B76145605937D6E309',
            '\xF3a1031a3544d762a5fC3f3230103B8572809B53',
            '\x38F221a229864f8761A291Fe93e53A46f8Ba425E'
          )
          AND "to" IN (
            '\x7259114Df363De5d42FDf00b705FAD7C85f8f795',
            '\x0CC36e3cc5eACA6d046b537703ae946874d57299',
            '\x1604C5e9aB488D66E983644355511DCEF5c32EDF',
            '\xcbA960001307A16ce8A9E326D73e92D53b446E81',
            '\xb932c4801240753604c768c991eb640BCD7C06EB',
            '\xc61C0F4961F2093A083f47a4b783ad260DeAF7eA',
            '\xbC35b70ccc8Ef4Ec1ccc34FaB60CcBBa162011e4',
            '\x4Df9Bb881E5e61034001440AaaFf2FB2932E2883',
            '\x8A362AA1c81ED0Ee2Ae677A8b59e0f563DD290Ba',
            '\xA4085c106c7a9A7AD0574865bbd7CaC5E1098195',
            '\x839Bb033738510AA6B4f78Af20f066bdC824B189',
            '\x1089f7bbF8c680Db92759A30d42ddFbA7C794BD2',
            '\xeA851503Ff416E34585d28C248918344C569B219',
            '\x49CbBFEDB15B5C22cac53Daf104512a5DE9C8457',
            '\x1a6525E4a4aB2E3aEa7ED3CF813e8ed07fA3446D'
          )
      ) x
    GROUP BY
      1,
      2,
      3,
      4
  ),
  asset_change_pt AS (
    SELECT
      datex,
      contract_address,
      vault_name,
      amm,
      SUM(value) AS pt_change
    FROM
      (
        SELECT
          date_trunc('DAY', evt_block_time) AS datex,
          contract_address,
          vault_name,
          amm,
          (-1) * value / 10 ^ (decimals) AS value
        FROM
          erc20."ERC20_evt_Transfer" t
          LEFT JOIN decimals d ON t.contract_address = d.pt
        WHERE
          "contract_address" IN (
            '\xEd1CAC496E38b42efB73125Df30B1CEe8e4626E0',
            '\x2B8692963C8eC4cdF30047a20F12C43E4d9aEf6C',
            '\x018d9Fc19821222B4dd92E1c65C95D55192E49f0',
            '\x4c0118C4682fe68e04c1d71d6168d05762Ff417d',
            '\x90e638C6039df98DbaF21b4dfB0C7D35c3c3Fe3E',
            '\xEeB7F670Bf2C092bb4196217b215BA5B4499f71c',
            '\xAf5335a9A014C48F49623aB6aE7461B63a91aD9d',
            '\x3Cdf203a1Dd04271de460034c1ccA5e20477bB19',
            '\x68b5515079FaFE7a41b636cd3B67a795dcD628c6',
            '\xA19862324Ef3c9E675d32d72868bfDDa147a5958',
            '\xa192a2381f9a2695adD598A32da0C35a7F92E919',
            '\xCda6bC3f0c60b2ea2Ca836319225f7848AFc40b8',
            '\x2B63eD6A73C01ADC79A4f5D39BCBF0E36d47f448',
            '\x137189D1342AaBE7Cd75B42B265E4647596aaa01',
            '\x2d31591f7a650579125bC9BC1622E07fFD219033'
          )
          AND "from" IN (
            '\x7259114Df363De5d42FDf00b705FAD7C85f8f795',
            '\x0CC36e3cc5eACA6d046b537703ae946874d57299',
            '\x1604C5e9aB488D66E983644355511DCEF5c32EDF',
            '\xcbA960001307A16ce8A9E326D73e92D53b446E81',
            '\xb932c4801240753604c768c991eb640BCD7C06EB',
            '\xc61C0F4961F2093A083f47a4b783ad260DeAF7eA',
            '\xbC35b70ccc8Ef4Ec1ccc34FaB60CcBBa162011e4',
            '\x4Df9Bb881E5e61034001440AaaFf2FB2932E2883',
            '\x8A362AA1c81ED0Ee2Ae677A8b59e0f563DD290Ba',
            '\xA4085c106c7a9A7AD0574865bbd7CaC5E1098195',
            '\x839Bb033738510AA6B4f78Af20f066bdC824B189',
            '\x1089f7bbF8c680Db92759A30d42ddFbA7C794BD2',
            '\xeA851503Ff416E34585d28C248918344C569B219',
            '\x49CbBFEDB15B5C22cac53Daf104512a5DE9C8457',
            '\x1a6525E4a4aB2E3aEa7ED3CF813e8ed07fA3446D'
          )
        UNION
        SELECT
          date_trunc('DAY', evt_block_time) AS datex,
          contract_address,
          vault_name,
          amm,
          value / 10 ^ (decimals) AS value
        FROM
          erc20."ERC20_evt_Transfer" t
          LEFT JOIN decimals d ON t.contract_address = d.pt
        WHERE
          "contract_address" IN (
            '\xEd1CAC496E38b42efB73125Df30B1CEe8e4626E0',
            '\x2B8692963C8eC4cdF30047a20F12C43E4d9aEf6C',
            '\x018d9Fc19821222B4dd92E1c65C95D55192E49f0',
            '\x4c0118C4682fe68e04c1d71d6168d05762Ff417d',
            '\x90e638C6039df98DbaF21b4dfB0C7D35c3c3Fe3E',
            '\xEeB7F670Bf2C092bb4196217b215BA5B4499f71c',
            '\xAf5335a9A014C48F49623aB6aE7461B63a91aD9d',
            '\x3Cdf203a1Dd04271de460034c1ccA5e20477bB19',
            '\x68b5515079FaFE7a41b636cd3B67a795dcD628c6',
            '\xA19862324Ef3c9E675d32d72868bfDDa147a5958',
            '\xa192a2381f9a2695adD598A32da0C35a7F92E919',
            '\xCda6bC3f0c60b2ea2Ca836319225f7848AFc40b8',
            '\x2B63eD6A73C01ADC79A4f5D39BCBF0E36d47f448',
            '\x137189D1342AaBE7Cd75B42B265E4647596aaa01',
            '\x2d31591f7a650579125bC9BC1622E07fFD219033'
          )
          AND "to" IN (
            '\x7259114Df363De5d42FDf00b705FAD7C85f8f795',
            '\x0CC36e3cc5eACA6d046b537703ae946874d57299',
            '\x1604C5e9aB488D66E983644355511DCEF5c32EDF',
            '\xcbA960001307A16ce8A9E326D73e92D53b446E81',
            '\xb932c4801240753604c768c991eb640BCD7C06EB',
            '\xc61C0F4961F2093A083f47a4b783ad260DeAF7eA',
            '\xbC35b70ccc8Ef4Ec1ccc34FaB60CcBBa162011e4',
            '\x4Df9Bb881E5e61034001440AaaFf2FB2932E2883',
            '\x8A362AA1c81ED0Ee2Ae677A8b59e0f563DD290Ba',
            '\xA4085c106c7a9A7AD0574865bbd7CaC5E1098195',
            '\x839Bb033738510AA6B4f78Af20f066bdC824B189',
            '\x1089f7bbF8c680Db92759A30d42ddFbA7C794BD2',
            '\xeA851503Ff416E34585d28C248918344C569B219',
            '\x49CbBFEDB15B5C22cac53Daf104512a5DE9C8457',
            '\x1a6525E4a4aB2E3aEa7ED3CF813e8ed07fA3446D'
          )
      ) x
    GROUP BY
      1,
      2,
      3,
      4
  ),
  generateDummyData_underlying AS (
    SELECT
      DISTINCT "generated_date",
      contract_address,
      vault_name,
      amm,
      0 AS underlying_change
    FROM
      asset_change_underlying
      CROSS JOIN generate_series('2021-12-23', NOW(), '1 day') as "generated_date"
  ),
  generateDummyData_pt AS (
    SELECT
      DISTINCT "generated_date",
      contract_address,
      vault_name,
      amm,
      0 AS pt_change
    FROM
      asset_change_pt
      CROSS JOIN generate_series('2021-12-23', NOW(), '1 day') as "generated_date"
  ),
  generateDummyData_fyt AS (
    SELECT
      DISTINCT "generated_date",
      contract_address,
      vault_name,
      amm,
      0 AS fyt_change
    FROM
      asset_change_fyt
      CROSS JOIN generate_series('2021-12-23', NOW(), '1 day') as "generated_date"
  ),
  tvl_underlying AS (
    SELECT
      datex,
      vault_name,
      amm,
      contract_address AS underlying_address,
      underlying_change,
      SUM(underlying_change) OVER (
        PARTITION BY vault_name, amm
        ORDER BY
          datex ASC
      ) AS tvl_underlying
    FROM
      (
        SELECT
          *
        FROM
          asset_change_underlying
        UNION ALL
        SELECT
          "generated_date",
          contract_address,
          vault_name,
          amm,
          underlying_change
        FROM
          generateDummyData_underlying
      ) x
  ),
  tvl_pt AS (
    SELECT
      datex,
      vault_name,
      amm,
      pt_change,
      SUM(pt_change) OVER (
        PARTITION BY vault_name
        ORDER BY
          datex ASC
      ) AS tvl_pt
    FROM
      (
        SELECT
          *
        FROM
          asset_change_pt
        UNION ALL
        SELECT
          "generated_date",
          contract_address,
          vault_name,
          amm,
          pt_change
        FROM
          generateDummyData_pt
      ) x
  ),
  tvl_fyt AS (
    SELECT
      datex,
      vault_name,
      amm,
      fyt_change,
      SUM(fyt_change) OVER (
        PARTITION BY vault_name
        ORDER BY
          datex ASC
      ) AS tvl_fyt
    FROM
      (
        SELECT
          *
        FROM
          asset_change_fyt
        UNION ALL
        SELECT
          "generated_date",
          contract_address,
          vault_name,
          amm,
          fyt_change
        FROM
          generateDummyData_fyt
      ) y
  )
  ,
tokens_x AS 
(
SELECT
  DISTINCT COALESCE(t.datex, p.datex, f.datex) AS datex,
  COALESCE(t.vault_name, p.vault_name, f.vault_name) AS vault_name,
  underlying_address,
  COALESCE(t.amm, p.amm, f.amm) AS amm,
  COALESCE(AVG(tvl_underlying),0) AS tvl_underlying,
  COALESCE(AVG(tvl_pt),0) AS tvl_pt,
  COALESCE(AVG(tvl_fyt),0) AS tvl_fyt
FROM
  tvl_underlying t
  FULL JOIN tvl_pt p ON p.datex = t.datex
  AND p.vault_name = t.vault_name
  FULL JOIN tvl_fyt f ON f.datex = t.datex
  AND f.vault_name = t.vault_name
GROUP BY
  1,
  2,
  3,
  4
ORDER BY
  1 DESC
  
  ),
  
  tokens AS (
  SELECT
    datex,
    vault_name,
    CASE 
        WHEN vault_name = 'frax3crv-IDLE' THEN '\x4CCaf1392a17203eDAb55a1F2aF3079A8Ac513E7'::BYTEA
        WHEN vault_name = 'c3Crypto-Yearn' THEN '\xcA3d75aC011BF5aD07a98d02f18225F9bD9A6BDF'::BYTEA
        ELSE underlying_address END AS underlying_address,
    amm,
    tvl_underlying,
    tvl_pt,
    tvl_fyt
FROM tokens_x
  ),
  
tvl_in_underlying_terms AS 
(SELECT
    t.datex,
    vault_name,
    t.amm,
    underlying_address,
    tvl_underlying,
    tvl_pt,
    tvl_pt*pt_price AS tvl_pt_underlying,
    tvl_fyt,
    tvl_fyt*fyt_price AS tvl_fyt_underlying
FROM
    tokens t
    LEFT JOIN dune_user_generated.apwine_pt_fyt_prices a ON a.datex = t.datex AND a.amm = t.amm
ORDER BY 1 DESC),

getLeadData_in_underlying_terms as (
    SELECT
          datex,
          amm,
          vault_name,
          underlying_address,
          tvl_underlying,
          tvl_pt_underlying,
          tvl_fyt_underlying,
          lead(datex, 1, NOW()) OVER (PARTITION BY vault_name ORDER BY datex asc) AS "next_hour"
    FROM tvl_in_underlying_terms
),

generateDates_in_underlying_terms AS
(
    SELECT 
        DISTINCT l.datex, 
        vault_name,
        amm,
        underlying_address
        FROM tvl_in_underlying_terms l
    CROSS JOIN 
    generate_series('2021-12-23',NOW(),'1 day') as datex
),

tvl_underlying_terms AS 
(SELECT 
    datex,
    vault_name,
    amm,
    CASE 
        WHEN vault_name = 'frax3crv-IDLE' THEN '\x4CCaf1392a17203eDAb55a1F2aF3079A8Ac513E7'::BYTEA
        WHEN vault_name = 'c3Crypto-Yearn' THEN '\xcA3d75aC011BF5aD07a98d02f18225F9bD9A6BDF'::BYTEA
        ELSE underlying_address END AS underlying_address,
    tvl_underlying,
    FIRST_VALUE(tvl_pt_underlying) OVER (PARTITION by vault_name,grp_close_pt ORDER BY datex ASC) as tvl_pt_underlying,
    FIRST_VALUE(tvl_fyt_underlying) OVER (PARTITION by vault_name, grp_close_fyt ORDER BY datex ASC) as tvl_fyt_underlying
FROM    
(SELECT
    datex,
    vault_name,
    amm,
    underlying_address,
    tvl_underlying,
    tvl_pt_underlying,
    SUM(CASE 
            WHEN tvl_pt_underlying IS NULL THEN 0 ELSE 1 END) OVER (PARTITION BY vault_name ORDER BY datex asc) AS grp_close_pt,
    tvl_fyt_underlying,
    SUM(CASE 
            WHEN tvl_fyt_underlying IS NOT NULL THEN 1 END) OVER (PARTITION BY vault_name ORDER BY datex asc) AS grp_close_fyt
FROM
    (SELECT
        gen.datex,
        gen.vault_name,
        gen.amm,
        gen.underlying_address,
        data.tvl_underlying,
        data.tvl_pt_underlying,
        data.tvl_fyt_underlying
    FROM getLeadData_in_underlying_terms data
    INNER JOIN generateDates_in_underlying_terms gen 
    ON data.vault_name = gen.vault_name
    AND data.datex <= gen.datex
    AND gen.datex < data."next_hour") x
    ) y
    )
    
    SELECT
        t.datex,
        t.vault_name,
        -- price,
        -- amm,
        -- t.underlying_address,
        t.tvl_underlying,
        u.tvl_underlying*price AS dollar_underlying,
        t.tvl_pt,
        u.tvl_pt_underlying,
        CASE WHEN u.tvl_pt_underlying*price IS NULL THEN t.tvl_pt*price ELSE u.tvl_pt_underlying*price END AS dollar_pt,
        t.tvl_fyt,
        u.tvl_fyt_underlying,
        u.tvl_fyt_underlying*price AS dollar_fyt,
        SUM(COALESCE(t.tvl_underlying*price, 0)+ COALESCE(CASE WHEN u.tvl_pt_underlying*price IS NULL THEN t.tvl_pt*price ELSE u.tvl_pt_underlying*price END, 0) + COALESCE(u.tvl_fyt_underlying*price, 0)) AS dollar_tvl
    FROM 
        tokens t
        LEFT JOIN tvl_underlying_terms u ON t.datex = u.datex AND t.amm = u.amm
        LEFT JOIN dune_user_generated.apwine_underlying_prices a ON a.datex = t.datex AND a.contract_address = t.underlying_address
    GROUP BY 1,2,3,4,5,6,7,8,9,10
    ORDER BY 1 DESC 
