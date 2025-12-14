WITH
  addresses AS (
    SELECT
      "to" AS adr
    FROM
      erc20."ERC20_evt_Transfer" tr
    WHERE
      contract_address = '/x4104b135DBC9609Fc1A9490E61369036497660c8'
  ),
  transfers AS (
    SELECT
      DAY,
      address,
      token_address,
      sum(amount) AS amount -- Net inflow or outflow per day
    FROM
      (
        SELECT
          date_trunc('day', evt_block_time) AS DAY,
          "to" AS address,
          tr.contract_address AS token_address,
          value AS amount
        FROM
          erc20."ERC20_evt_Transfer" tr --INNER JOIN addresses ad ON tr."to" = ad.adr
        WHERE
          contract_address = '\x4104b135DBC9609Fc1A9490E61369036497660c8'
        UNION ALL
        SELECT
          date_trunc('day', evt_block_time) AS DAY,
          "from" AS address,
          tr.contract_address AS token_address,
          - value AS amount
        FROM
          erc20."ERC20_evt_Transfer" tr --INNER JOIN addresses ad ON tr."from" = ad.adr
        WHERE
          contract_address = '\x4104b135DBC9609Fc1A9490E61369036497660c8'
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
      -- balance per day with a transfer
      lead(DAY, 1, now()) OVER (
        PARTITION BY address
        ORDER BY
          t.day
      ) AS next_day -- the day after a day with a transfer
    FROM
      transfers t
  ),
  days AS (
    SELECT
      generate_series('2020-08-28', date_trunc('day', NOW()), '1 day') AS DAY -- Generate all days since the first contract
  ),
  balance_all_days AS (
    SELECT
      d.day,
      address,
      SUM(balance) AS balance
    FROM
      balances_with_gap_days b
      INNER JOIN days d ON b.day <= d.day
      AND d.day < b.next_day -- Yields an observation for every day after the first transfer until the next day with transfer
      --INNER JOIN erc20.tokens erc ON b.token_address = erc.contract_address
    GROUP BY
      1,
      2
    ORDER BY
      1,
      2
  )
SELECT
  b.day AS "Date",
  SUM(
    CASE
      WHEN address IN (
        '\xfbb1b73c4f0bda4f67dca266ce6ef42f520fbb98',
        '\xE94b04a0FeD112f3664e45adb2B8915693dD5FF3',
        '\x66f820a414680B5bcda5eECA5dea238543F42054',
        '\x8533a0bd9310eb63e7cc8e1116c18a3d67b1976a',
        '\x274F3c32C90517975e29Dfc209a23f315c1e5Fc7',
        '\x2FAF487A4414Fe77e2327F0bf4AE2a264a776AD2',
        '\xC098B2a3Aa256D2140208C3de6543aAEf5cd3A94',
        '\x0D0707963952f2fBA59dD06f2b425ace40b492Fe',
        '\x7793cD85c11a924478d358D49b05b37E91B5810F',
        '\x1C4b70a3968436B9A0a9cf5205c787eb81Bb558c',
        '\x2a0c0dbecc7e4d658f48e01e3fa353f44050c208',
        '\xa7a7899d944fe658c4b0a1803bab2f490bd3849e',
        '\x1b3d794bbeecd9240f46dbb3b79f4f71a972e00a',
        '\xCE84867c3c02B05dc570d0135103d3fB9CC19433',
        '\xC8d02f2669eF9aABE6B3b75E2813695AeD63748d',
        '\xB4e16d0168e52d35CaCD2c6185b44281Ec28C9Dc',
        '\xc92bB84302412331855C3e383725967aA26C1806',
        '\x19E286157200418d6A1f7D1df834b82E65C920AA',
        '\x73A6a761FE483bA19DeBb8f56aC5bbF14c0cdad1',
        '\x75e89d5979E4f6Fba9F97c104c2F0AFB3F1dcB88',
        '\x0211f3ceDbEf3143223D3ACF0e589747933e8527',
        '\xb9ee1e551f538A464E8F8C41E9904498505B49b0',
        '\x795065dCc9f64b5614C407a6EFDC400DA6221FB0',
        '\xBa87dC891945dbB3CAeEaF822DE208D7eA89B298',
        '\x680A025Da7b1be2c204D7745e809919bCE074026',
        '\x812dCbf51F5A7A000dF6e7aAA8557290fd41cf41',
        '\xc599f66e20a8420894d980624671937d5d7e4ea5',
        '\x321198908bd33b066252d63d363667e3f7094a34',
        '\xbff6cbf2e7d2cd0705329c735a37be33241298e9',
        '\x7ee3be9a82f051401ca028db1825ac2640884d0a',
        '\x513d5f1df52eb1b70ffe6b89f3685920fc6c5d89',
        '\x255ed38500577a0c85cf8108c0097da80a76c5e1',
        '\x337b8d30da6f7dc740693d1d9e7a1fadca3be4ed',
        '\x68b22215FF74E3606BD5E6c1DE8c2D68180c85F7',
        '\x6cC5F688a315f3dC28A7781717a9A798a59fDA7b',
        '\xcce8d59affdd93be338fc77fa0a298c2cb65da59',
        '\xf7793d27a1b76cdf14db7c83e82c772cf7c92910',
        '\x59a5208B32e627891C389EbafC644145224006E8',
        '\xA12431D0B9dB640034b0CDFcEEF9CCe161e62be4',
        '\x9c67e141c0472115aa1b98bd0088418be68fd249',
        '\x5894110995B8c8401Bd38262bA0c8EE41d4E4658',
        '\x67e4BBE50Fbc74633dFd9F7683465c02Af896541',
        '\xCC1AaC4513F751eFfC94E259daf8A37b76f9db75',
        '\x4f8AF8E8734D02a21D73e2a4fb29941f35CbbEAC',
        '\xC39e562DEFC6DDD1F44ee698Cf9303092B86051d',
        '\x32708887dbaf9f3c3a60e79636879e46b5896e00',
        '\x4ab362974d6077e35fd9c0009ca40f012a2daf2c',
        '\x406ffef38af87a170babc5b9b853d2ecef3e596e',
        '\xf3b6a8b21d456c862f903c9c372c1a3e922b6b7f',
        '\x36d6498157007b9a8b359f7db9910529e7ff5917',
        '\x53B0a526e67AEc8F151297f8b6B20D0D8A7b9129',
        '\xBe0e4E74897275F5e5a0a184B112B20860aD4FAC',
        '\x2910543af39aba0cd09dbb2d50200b3e800a63d2',
        '\x0a869d79a7052c7f1b55a8ebabbea3420f0d1e13',
        '\xe853c56864a2ebe4576a807d26fdc4a0ada51919',
        '\x267be1c1d684f78cb4f6a176c4911b741e4ffdc0',
        '\xfa52274dd61e1643d2205169732f29114bc240b3',
        '\x53d284357ec70ce289d6d64134dfac8e511c8a3d',
        '\xab5c66752a9e8167967685f1450532fb96d5d24f',
        '\x6748f50f686bfbca6fe8ad62b22228b87f31ff2b',
        '\xfdb16996831753d5331ff813c29a93c76834a0ad',
        '\xeee28d484628d41a82d01e21d12e2e78d69920da',
        '\x5c985e89dde482efe97ea9f1950ad149eb73829b',
        '\xdc76cd25977e0a5ae17155770273ad58648900d3',
        '\xadb2b42f6bd96f5c65920b9ac88619dce4166f94',
        '\xa8660c8ffd6d578f657b72c0c811284aef0b735e',
        '\x1062a747393198f70f71ec65a582423dba7e5ab3',
        '\xe93381fb4c4f14bda253907b18fad305d799241a',
        '\xfa4b5be3f2f84f56703c42eb22142744e95a2c58',
        '\x46705dfff24256421a05d056c29e81bdc09723b8',
        '\x32598293906b5b17c27d657db3ad2c9b3f3e4265',
        '\x5861b8446a2f6e19a067874c133f04c578928727',
        '\x926fc576b7facf6ae2d08ee2d4734c134a743988',
        '\xeec606a66edb6f497662ea31b5eb1610da87ab5f',
        '\x7ef35bb398e0416b81b019fea395219b65c52164',
        '\x229b5c097f9b35009ca1321ad2034d4b3d5070f6',
        '\xd8a83b72377476d0a66683cde20a8aad0b628713',
        '\x90e9ddd9d8d5ae4e3763d0cf856c97594dea7325',
        '\x18916e1a2933cb349145a280473a5de8eb6630cb',
        '\x6f48a3e70f0251d1e83a989e62aaa2281a6d5380',
        '\xf056f435ba0cc4fcd2f1b17e3766549ffc404b94',
        '\x137ad9c4777e1d36e4b605e745e8f37b2b62e9c5',
        '\x5401dbf7da53e1c9dbf484e3d69505815f2f5e6e',
        '\x034f854b44d28e26386c1bc37ff9b20c6380b00d',
        '\x0577a79cfc63bbc0df38833ff4c4a3bf2095b404',
        '\x0c6c34cdd915845376fb5407e0895196c9dd4eec',
        '\x794d28ac31bcb136294761a556b68d2634094153',
        '\xfd54078badd5653571726c3370afb127351a6f26',
        '\xb4cd0386d2db86f30c1a11c2b8c4f4185c1dade9',
        '\x4d77a1144dc74f26838b69391a6d3b1e403d0990',
        '\x28ffe35688ffffd0659aee2e34778b0ae4e193ad',
        '\xcac725bef4f114f728cbcfd744a731c2a463c3fc',
        '\x73f8fc2e74302eb2efda125a326655acf0dc2d1b',
        '\x0a98fb70939162725ae66e626fe4b52cff62c2e5',
        '\xf66852bc122fd40bfecc63cd48217e88bda12109',
        '\x1151314c646ce4e0efd76d1af4760ae66a9fe30f',
        '\x742d35cc6634c0532925a3b844bc454e4438f44e',
        '\x876eabf441b2ee5b5b0554fd502a8e0600950cfa',
        '\x6262998ced04146fa42253a5c0af90ca02dfd2a3',
        '\x46340b20830761efd32832a74d7169b29feb9758',
        '\xd24400ae8bfebb18ca49be86258a3c749cf46853',
        '\x6fc82a5fe25a5cdb58bc74600a40a69c065263f8',
        '\x61edcdf5bb737adffe5043706e7c5bb1f1a56eea',
        '\x51836A753E344257B361519E948ffCAF5fb8d521',
        '\x9CbADD5Ce7E14742F70414A6DcbD4e7bB8712719',
        '\x32Be343B94f860124dC4fEe278FDCBD38C102D88',
        '\x209c4784AB1E8183Cf58cA33cb740efbF3FC18EF',
        '\xb794F5eA0ba39494cE839613fffBA74279579268',
        '\xA910f92ACdAf488fa6eF02174fb86208Ad7722ba',
        '\x3f5ce5fbfe3e9af3971dd833d26ba9b5c936f0be',
        '\xd551234ae421e3bcba99a0da6d736074f22192ff',
        '\x564286362092d8e7936f0549571a803b203aaced',
        '\x0681d8db095565fe8a346fa0277bffde9c0edbbf',
        '\xfe9e8709d3215310075d67e3ed32a380ccf451c8',
        '\x4e9ce36e442e55ecd9025b9a6e0d88485d628a67',
        '\xbe0eb53f46cd790cd13851d5eff43d12404d33e8',
        '\xf977814e90da44bfa03b6295a0616a897441acec',
        '\x001866ae5b3de6caa5a51543fd9fb64f524f5478',
        '\x85b931a32a0725be14285b66f1a22178c672d69b',
        '\x708396f17127c42383e3b9014072679b2f60b82f',
        '\xe0f0cfde7ee664943906f17f7f14342e76a5cec7',
        '\x8f22f2063d253846b53609231ed80fa571bc0c8f',
        '\x28c6c06298d514db089934071355e5743bf21d60',
        '\x21a31ee1afc51d94c2efccaa2092ad1028285549',
        '\x6cbefa95e42960E579C2A3058C05C6A08e2498e9',
        '\x5f65f7b609678448494de4c87521cdf6cef1e932'
      ) then balance / 1e18
    END
  ) as "Exchanges",
--   SUM(
--     CASE
--       WHEN address IN (
--         '\xeae57ce9cc1984f202e15e038b964bb8bdf7229a',
--         '\xf92cD566Ea4864356C5491c177A430C222d7e678',
--         '\x2dccdb493827e15a5dc8f8b72147e6c4a5620857',
--         '\x6a39909e805A3eaDd2b61fFf61147796ca6aBB47',
--         '\x10c6b61DbF44a083Aec3780aCF769C77BE747E23',
--         '\xc564ee9f21ed8a2d8e7e76c085740d5e4c5fafbe',
--         '\xdac7bb7ce4ff441a235f08408e632fa1d799a147',
--         '\xe78388b4ce79068e89bf8aa7f218ef6b9ab0e9d0',
--         '\x401F6c983eA34274ec46f84D70b31C151321188b',
--         '\x88ad09518695c6c3712AC10a214bE5109a655671',
--         '\x4aa42145Aa6Ebf72e164C9bBC74fbD3788045016',
--         '\x467194771dae2967aef3ecbedd3bf9a310c76c65',
--         '\x99C9fc46f92E8a1c0deC1b1747d010903E884bE1',
--         '\x5Fd79D46EBA7F351fe49BFF9E87cdeA6c821eF9f',
--         '\x533e3c0e6b48010873b947bddc4721b1bdff9648',
--         '\x47ac0fb4f2d84898e4d9e7b4dab3c24507a6d503',
--         '\x011b6e24ffb0b5f5fcc564cf4183c5bbbc96d515',
--         '\xcEe284F754E854890e311e3280b767F80797180d',
--         '\xa3A7B6F88361F48403514059F1F16C8E78d60EeC',
--         '\x737901bea3eeb88459df9ef1be8ff3ae1b42a2ba',
--         '\x8ECa806Aecc86CE90Da803b080Ca4E3A9b8097ad',
--         '\xaBEA9132b05A70803a4E85094fD0e1800777fBEF',
--         '\xdc1664458d2f0B6090bEa60A8793A4E66c2F1c00',
--         '\x23ddd3e3692d1861ed57ede224608875809e127f'
--       ) then balance / 1e18
--     END
--   ) as "Other Chains/L2s",
  SUM(
    CASE
      WHEN address IN ('\xC5ca1EBF6e912E49A6a70Bb0385Ea065061a4F09') then balance / 1e18
    END
  ) as "veAPW",
  SUM(
    CASE
      WHEN address IN ('\xcaf8703f8664731ced11f63bb0570e53ab4600a9') then balance / 1e18
    END
  ) as "Curve LP tAPW/APW",
  SUM(
    CASE
      WHEN address IN ('\x16d96ba86512b4f8d10bd74b1061d9f576d9c55d') then balance / 1e18
    END
  ) as "Vesting",
  SUM(
    CASE
      WHEN address IN ('\xDbbfc051D200438dd5847b093B22484B842de9E7') then balance / 1e18
    END
  ) as "DAO Treasury",
  SUM(
    CASE
      WHEN address IN ('\xDc0b02849Bb8E0F126a216A2840275Da829709B0') then balance / 1e18
    END
  ) as "Tokemak tAPW",
  SUM(
    CASE
      WHEN address IN ('\x073d987513ca27ae5801f389c6ec5bd8c84909b2') then balance / 1e18
    END
  ) as "Bancor V2 APW/ETH",
  SUM(
    CASE
      WHEN address IN ('\x53162d78dca413d9e28cf62799d17a9e278b60e8') then balance / 1e18
    END
  ) as "Sushi LP APW/ETH",
  SUM(
    CASE
      WHEN address IN ('\x40ec5b33f54e0e8a33a975908c5ba1c14e5bbbdf') then balance / 1e18
    END
  ) as "Polygon Bridge",
  SUM(
    CASE
      WHEN address IN ('\xf930ebbd05ef8b25b1797b9b2109ddc9b0d43063') then balance / 1e18
    END
  ) as "Other DAOs Holdings",
  SUM(
    CASE
      WHEN address IN (
        '\x7d42bf24f22ed0fb0a0473a504817ac5c44f51fb',
        '\x1a3e8de7e155fd91b7b3726ee20498762756227f',
        '\x6D496477692320D67B8f211EDe5097F3C89abf63',
        -- '\xca67f76bccce3f856fcd38825e3afc43386ec806',
        -- '\x8df8fe02cfbdaaac04b4ef982c456eaa8eb8aeda',
        '\x2af9b355a578e8bf422bb7ebb5ee7434f24d5ef3',
        '\x8Dd1Bb800Cc57fbF61560B53b8A1a46867C2Ce17',
        -- '\x976644c7ed9784e5758bb6584dbe3b91420e3463',
        -- '\x27eda9955c50969d30cfeb97566c978720a67e59',
        '\x639d20f70bcc01a25355720ef6590beab6e4a0e7'
      ) then balance / 1e18
    END
  ) as "Mainnet SCs",
  SUM(
    CASE
      WHEN address NOT IN (
        '\x8Dd1Bb800Cc57fbF61560B53b8A1a46867C2Ce17',
        '\xf930ebbd05ef8b25b1797b9b2109ddc9b0d43063',
        '\x7d42bf24f22ed0fb0a0473a504817ac5c44f51fb',
        '\x1a3e8de7e155fd91b7b3726ee20498762756227f',
        -- '\xca67f76bccce3f856fcd38825e3afc43386ec806',
        -- '\x8df8fe02cfbdaaac04b4ef982c456eaa8eb8aeda',
        '\x2af9b355a578e8bf422bb7ebb5ee7434f24d5ef3',
        '\x6D496477692320D67B8f211EDe5097F3C89abf63',
        -- '\x976644c7ed9784e5758bb6584dbe3b91420e3463',
        -- '\x27eda9955c50969d30cfeb97566c978720a67e59',
        '\x639d20f70bcc01a25355720ef6590beab6e4a0e7',
        '\xDbbfc051D200438dd5847b093B22484B842de9E7',
        '\xcaf8703f8664731ced11f63bb0570e53ab4600a9',
        '\x16d96ba86512b4f8d10bd74b1061d9f576d9c55d',
        '\xC5ca1EBF6e912E49A6a70Bb0385Ea065061a4F09',
        '\x073d987513ca27ae5801f389c6ec5bd8c84909b2',
        '\xDc0b02849Bb8E0F126a216A2840275Da829709B0',
        '\x40ec5b33f54e0e8a33a975908c5ba1c14e5bbbdf',
        '\x53162d78dca413d9e28cf62799d17a9e278b60e8',
        '\x3F148612315AaE2514AC630D6FAf0D94B8Cd8E33',
        '\x1494CA1F11D487c2bBe4543E90080AeBa4BA3C2b',
        '\x2d615795a8bdb804541C69798F13331126BA0c09',
        '\x6cbefa95e42960E579C2A3058C05C6A08e2498e9',
        '\xfbb1b73c4f0bda4f67dca266ce6ef42f520fbb98',
        '\xE94b04a0FeD112f3664e45adb2B8915693dD5FF3',
        '\x5f65f7b609678448494de4c87521cdf6cef1e932',
        '\x66f820a414680B5bcda5eECA5dea238543F42054',
        '\x8533a0bd9310eb63e7cc8e1116c18a3d67b1976a',
        '\x274F3c32C90517975e29Dfc209a23f315c1e5Fc7',
        '\x2FAF487A4414Fe77e2327F0bf4AE2a264a776AD2',
        '\xC098B2a3Aa256D2140208C3de6543aAEf5cd3A94',
        '\x0D0707963952f2fBA59dD06f2b425ace40b492Fe',
        '\x7793cD85c11a924478d358D49b05b37E91B5810F',
        '\x1C4b70a3968436B9A0a9cf5205c787eb81Bb558c',
        '\x2a0c0dbecc7e4d658f48e01e3fa353f44050c208',
        '\xa7a7899d944fe658c4b0a1803bab2f490bd3849e',
        '\x1b3d794bbeecd9240f46dbb3b79f4f71a972e00a',
        '\xCE84867c3c02B05dc570d0135103d3fB9CC19433',
        '\xC8d02f2669eF9aABE6B3b75E2813695AeD63748d',
        '\xB4e16d0168e52d35CaCD2c6185b44281Ec28C9Dc',
        '\xc92bB84302412331855C3e383725967aA26C1806',
        '\x19E286157200418d6A1f7D1df834b82E65C920AA',
        '\x73A6a761FE483bA19DeBb8f56aC5bbF14c0cdad1',
        '\x75e89d5979E4f6Fba9F97c104c2F0AFB3F1dcB88',
        '\x0211f3ceDbEf3143223D3ACF0e589747933e8527',
        '\xb9ee1e551f538A464E8F8C41E9904498505B49b0',
        '\x795065dCc9f64b5614C407a6EFDC400DA6221FB0',
        '\xBa87dC891945dbB3CAeEaF822DE208D7eA89B298',
        '\x680A025Da7b1be2c204D7745e809919bCE074026',
        '\x812dCbf51F5A7A000dF6e7aAA8557290fd41cf41',
        '\xc599f66e20a8420894d980624671937d5d7e4ea5',
        '\x321198908bd33b066252d63d363667e3f7094a34',
        '\xbff6cbf2e7d2cd0705329c735a37be33241298e9',
        '\x7ee3be9a82f051401ca028db1825ac2640884d0a',
        '\x513d5f1df52eb1b70ffe6b89f3685920fc6c5d89',
        '\x255ed38500577a0c85cf8108c0097da80a76c5e1',
        '\x337b8d30da6f7dc740693d1d9e7a1fadca3be4ed',
        '\x68b22215FF74E3606BD5E6c1DE8c2D68180c85F7',
        '\x6cC5F688a315f3dC28A7781717a9A798a59fDA7b',
        '\xcce8d59affdd93be338fc77fa0a298c2cb65da59',
        '\xf7793d27a1b76cdf14db7c83e82c772cf7c92910',
        '\x59a5208B32e627891C389EbafC644145224006E8',
        '\xA12431D0B9dB640034b0CDFcEEF9CCe161e62be4',
        '\x9c67e141c0472115aa1b98bd0088418be68fd249',
        '\x5894110995B8c8401Bd38262bA0c8EE41d4E4658',
        '\x67e4BBE50Fbc74633dFd9F7683465c02Af896541',
        '\xCC1AaC4513F751eFfC94E259daf8A37b76f9db75',
        '\x4f8AF8E8734D02a21D73e2a4fb29941f35CbbEAC',
        '\xC39e562DEFC6DDD1F44ee698Cf9303092B86051d',
        '\x32708887dbaf9f3c3a60e79636879e46b5896e00',
        '\x4ab362974d6077e35fd9c0009ca40f012a2daf2c',
        '\x406ffef38af87a170babc5b9b853d2ecef3e596e',
        '\xf3b6a8b21d456c862f903c9c372c1a3e922b6b7f',
        '\x36d6498157007b9a8b359f7db9910529e7ff5917',
        '\x53B0a526e67AEc8F151297f8b6B20D0D8A7b9129',
        '\xBe0e4E74897275F5e5a0a184B112B20860aD4FAC',
        '\x2910543af39aba0cd09dbb2d50200b3e800a63d2',
        '\x0a869d79a7052c7f1b55a8ebabbea3420f0d1e13',
        '\xe853c56864a2ebe4576a807d26fdc4a0ada51919',
        '\x267be1c1d684f78cb4f6a176c4911b741e4ffdc0',
        '\xfa52274dd61e1643d2205169732f29114bc240b3',
        '\x53d284357ec70ce289d6d64134dfac8e511c8a3d',
        '\xab5c66752a9e8167967685f1450532fb96d5d24f',
        '\x6748f50f686bfbca6fe8ad62b22228b87f31ff2b',
        '\xfdb16996831753d5331ff813c29a93c76834a0ad',
        '\xeee28d484628d41a82d01e21d12e2e78d69920da',
        '\x5c985e89dde482efe97ea9f1950ad149eb73829b',
        '\xdc76cd25977e0a5ae17155770273ad58648900d3',
        '\xadb2b42f6bd96f5c65920b9ac88619dce4166f94',
        '\xa8660c8ffd6d578f657b72c0c811284aef0b735e',
        '\x1062a747393198f70f71ec65a582423dba7e5ab3',
        '\xe93381fb4c4f14bda253907b18fad305d799241a',
        '\xfa4b5be3f2f84f56703c42eb22142744e95a2c58',
        '\x46705dfff24256421a05d056c29e81bdc09723b8',
        '\x32598293906b5b17c27d657db3ad2c9b3f3e4265',
        '\x5861b8446a2f6e19a067874c133f04c578928727',
        '\x926fc576b7facf6ae2d08ee2d4734c134a743988',
        '\xeec606a66edb6f497662ea31b5eb1610da87ab5f',
        '\x7ef35bb398e0416b81b019fea395219b65c52164',
        '\x229b5c097f9b35009ca1321ad2034d4b3d5070f6',
        '\xd8a83b72377476d0a66683cde20a8aad0b628713',
        '\x90e9ddd9d8d5ae4e3763d0cf856c97594dea7325',
        '\x18916e1a2933cb349145a280473a5de8eb6630cb',
        '\x6f48a3e70f0251d1e83a989e62aaa2281a6d5380',
        '\xf056f435ba0cc4fcd2f1b17e3766549ffc404b94',
        '\x137ad9c4777e1d36e4b605e745e8f37b2b62e9c5',
        '\x5401dbf7da53e1c9dbf484e3d69505815f2f5e6e',
        '\x034f854b44d28e26386c1bc37ff9b20c6380b00d',
        '\x0577a79cfc63bbc0df38833ff4c4a3bf2095b404',
        '\x0c6c34cdd915845376fb5407e0895196c9dd4eec',
        '\x794d28ac31bcb136294761a556b68d2634094153',
        '\xfd54078badd5653571726c3370afb127351a6f26',
        '\xb4cd0386d2db86f30c1a11c2b8c4f4185c1dade9',
        '\x4d77a1144dc74f26838b69391a6d3b1e403d0990',
        '\x28ffe35688ffffd0659aee2e34778b0ae4e193ad',
        '\xcac725bef4f114f728cbcfd744a731c2a463c3fc',
        '\x73f8fc2e74302eb2efda125a326655acf0dc2d1b',
        '\x0a98fb70939162725ae66e626fe4b52cff62c2e5',
        '\xf66852bc122fd40bfecc63cd48217e88bda12109',
        '\x1151314c646ce4e0efd76d1af4760ae66a9fe30f',
        '\x742d35cc6634c0532925a3b844bc454e4438f44e',
        '\x876eabf441b2ee5b5b0554fd502a8e0600950cfa',
        '\x6262998ced04146fa42253a5c0af90ca02dfd2a3',
        '\x46340b20830761efd32832a74d7169b29feb9758',
        '\xd24400ae8bfebb18ca49be86258a3c749cf46853',
        '\x6fc82a5fe25a5cdb58bc74600a40a69c065263f8',
        '\x61edcdf5bb737adffe5043706e7c5bb1f1a56eea',
        '\x51836A753E344257B361519E948ffCAF5fb8d521',
        '\x9CbADD5Ce7E14742F70414A6DcbD4e7bB8712719',
        '\x32Be343B94f860124dC4fEe278FDCBD38C102D88',
        '\x209c4784AB1E8183Cf58cA33cb740efbF3FC18EF',
        '\xb794F5eA0ba39494cE839613fffBA74279579268',
        '\xA910f92ACdAf488fa6eF02174fb86208Ad7722ba',
        '\x3f5ce5fbfe3e9af3971dd833d26ba9b5c936f0be',
        '\xd551234ae421e3bcba99a0da6d736074f22192ff',
        '\x564286362092d8e7936f0549571a803b203aaced',
        '\x0681d8db095565fe8a346fa0277bffde9c0edbbf',
        '\xfe9e8709d3215310075d67e3ed32a380ccf451c8',
        '\x4e9ce36e442e55ecd9025b9a6e0d88485d628a67',
        '\xbe0eb53f46cd790cd13851d5eff43d12404d33e8',
        '\xf977814e90da44bfa03b6295a0616a897441acec',
        '\x001866ae5b3de6caa5a51543fd9fb64f524f5478',
        '\x85b931a32a0725be14285b66f1a22178c672d69b',
        '\x708396f17127c42383e3b9014072679b2f60b82f',
        '\xe0f0cfde7ee664943906f17f7f14342e76a5cec7',
        '\x8f22f2063d253846b53609231ed80fa571bc0c8f',
        '\x28c6c06298d514db089934071355e5743bf21d60',
        '\x21a31ee1afc51d94c2efccaa2092ad1028285549',
        '\xeae57ce9cc1984f202e15e038b964bb8bdf7229a',
        '\xf92cD566Ea4864356C5491c177A430C222d7e678',
        '\x2dccdb493827e15a5dc8f8b72147e6c4a5620857',
        '\x6a39909e805A3eaDd2b61fFf61147796ca6aBB47',
        '\x10c6b61DbF44a083Aec3780aCF769C77BE747E23',
        '\xc564ee9f21ed8a2d8e7e76c085740d5e4c5fafbe',
        '\xdac7bb7ce4ff441a235f08408e632fa1d799a147',
        '\xe78388b4ce79068e89bf8aa7f218ef6b9ab0e9d0',
        '\x40ec5b33f54e0e8a33a975908c5ba1c14e5bbbdf',
        '\x401F6c983eA34274ec46f84D70b31C151321188b',
        '\x88ad09518695c6c3712AC10a214bE5109a655671',
        '\x4aa42145Aa6Ebf72e164C9bBC74fbD3788045016',
        '\x467194771dae2967aef3ecbedd3bf9a310c76c65',
        '\x99C9fc46f92E8a1c0deC1b1747d010903E884bE1',
        '\x5Fd79D46EBA7F351fe49BFF9E87cdeA6c821eF9f',
        '\x533e3c0e6b48010873b947bddc4721b1bdff9648',
        '\x47ac0fb4f2d84898e4d9e7b4dab3c24507a6d503',
        '\x011b6e24ffb0b5f5fcc564cf4183c5bbbc96d515',
        '\xcEe284F754E854890e311e3280b767F80797180d',
        '\xa3A7B6F88361F48403514059F1F16C8E78d60EeC',
        '\x737901bea3eeb88459df9ef1be8ff3ae1b42a2ba',
        '\x8ECa806Aecc86CE90Da803b080Ca4E3A9b8097ad',
        '\xaBEA9132b05A70803a4E85094fD0e1800777fBEF',
        '\xdc1664458d2f0B6090bEa60A8793A4E66c2F1c00',
        '\x23ddd3e3692d1861ed57ede224608875809e127f',
        '\x8798249c2E607446EfB7Ad49eC89dD1865Ff4272',
        '\xe94B5EEC1fA96CEecbD33EF5Baa8d00E4493F4f3',
        '\xcbe6b83e77cdc011cc18f6f0df8444e5783ed982'
      ) then balance / 1e18
    END
  ) as "Mainnet Holders"
FROM
  balance_all_days b
WHERE
  balance > 0
  AND b.day > '2020-08-28'
GROUP BY
  "Date"
ORDER BY
  "Date"