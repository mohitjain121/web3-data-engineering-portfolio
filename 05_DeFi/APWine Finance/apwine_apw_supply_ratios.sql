WITH
  circ_supply AS (
    SELECT
      datex,
      SUM(circ_supply) OVER (
        ORDER BY
          datex
      ) AS circ_supply
    FROM
      (
        SELECT
          date_trunc('DAY', evt_block_time) as datex,
          SUM((-1) * value / (1e18)) as circ_supply
        FROM
          erc20."ERC20_evt_Transfer"
        WHERE
          contract_address = '\x4104b135DBC9609Fc1A9490E61369036497660c8' -- token contract address
          AND "from" != '\x4104b135DBC9609Fc1A9490E61369036497660c8'
          AND "from" != '\x0000000000000000000000000000000000000000'
          AND "from" NOT IN (
            '\x16d96ba86512b4f8d10bd74b1061d9f576d9c55d', --Vesting Account
        '\xC5ca1EBF6e912E49A6a70Bb0385Ea065061a4F09', --Voting Escrow Accunt
        '\xdbbfc051d200438dd5847b093b22484b842de9e7', --Treasury
        '\x2aF9b355A578e8bF422bB7EbB5EE7434F24d5ef3', --Sushi Rewarder
        '\x1A3E8De7e155fd91B7B3726EE20498762756227f', --New rewarder mainnet
        '\x639D20F70bcc01A25355720EF6590Beab6e4a0E7', --Merkletree
        '\x6610c566B01ad2076CFdFf3cf68515aaE76a9035', --Old rewarder mainnet 
        '\x7b4396aac0FF6A948546F4A5200aB9592B28251C', --Polygon DAO Main Msig
        '\xAbae9C064bf1fd92Fcfc7052D23De7029C6bbD95', --Polygon Bounties Msig
        '\x150fb0cfa5bf3d4023ba198c725b6dcbc1577f21', --rewarder polygon
        '\x277A2C1F890D527434cA5eA1286019e083c5A8ee', --Cometh rewarder
        '\x8E4b31931aE58Fc0479BeE2FF5Cf9961832045eC', --Cometh staking contract 
        '\x9e9d9F1217D9efF596CBdFa044e19371d440E711', --Nested reserve
        '\x40ec5b33f54e0e8a33a975908c5ba1c14e5bbbdf' --Polygon Bridge
          )
        GROUP BY
          1
        UNION
        SELECT
          date_trunc('DAY', evt_block_time) as datex,
          SUM(value / (1e18)) as circ_supply
        FROM
          erc20."ERC20_evt_Transfer"
        WHERE
          contract_address = '\x4104b135DBC9609Fc1A9490E61369036497660c8' -- token contract address
          AND "to" != '\x4104b135DBC9609Fc1A9490E61369036497660c8'
          AND "to" != '\x0000000000000000000000000000000000000000'
          AND "to" NOT IN (
            '\x16d96ba86512b4f8d10bd74b1061d9f576d9c55d', --Vesting Account
        '\xC5ca1EBF6e912E49A6a70Bb0385Ea065061a4F09', --Voting Escrow Accunt
        '\xdbbfc051d200438dd5847b093b22484b842de9e7', --Treasury
        '\x2aF9b355A578e8bF422bB7EbB5EE7434F24d5ef3', --Sushi Rewarder
        '\x1A3E8De7e155fd91B7B3726EE20498762756227f', --New rewarder mainnet
        '\x639D20F70bcc01A25355720EF6590Beab6e4a0E7', --Merkletree
        '\x6610c566B01ad2076CFdFf3cf68515aaE76a9035', --Old rewarder mainnet 
        '\x7b4396aac0FF6A948546F4A5200aB9592B28251C', --Polygon DAO Main Msig
        '\xAbae9C064bf1fd92Fcfc7052D23De7029C6bbD95', --Polygon Bounties Msig
        '\x150fb0cfa5bf3d4023ba198c725b6dcbc1577f21', --rewarder polygon
        '\x277A2C1F890D527434cA5eA1286019e083c5A8ee', --Cometh rewarder
        '\x8E4b31931aE58Fc0479BeE2FF5Cf9961832045eC', --Cometh staking contract 
        '\x9e9d9F1217D9efF596CBdFa044e19371d440E711', --Nested reserve
        '\x40ec5b33f54e0e8a33a975908c5ba1c14e5bbbdf' --Polygon Bridge
          )
        GROUP BY
          1
      ) t
  ),
  supply_locked AS (
    SELECT
      datex,
      SUM(amount) OVER (
        ORDER BY
          datex
      ) AS supply_locked
    FROM
      (
        SELECT
          date_trunc('DAY', evt_block_time) as datex,
          SUM((-1) * value) / 1e18 AS amount
        FROM
          erc20."ERC20_evt_Transfer"
        WHERE
          "from" = '\xC5ca1EBF6e912E49A6a70Bb0385Ea065061a4F09' --Voting Escrow Account
        GROUP BY
          1
        UNION ALL
        SELECT
          date_trunc('DAY', evt_block_time) as datex,
          SUM(value) / 1e18 AS amount
        FROM
          erc20."ERC20_evt_Transfer"
        where
          "to" = '\xC5ca1EBF6e912E49A6a70Bb0385Ea065061a4F09' --Voting Escrow Account
        GROUP BY
          1
      ) x
  )
SELECT
  DISTINCT c.datex,
  50000000 AS total_supply,
  circ_supply,
  supply_locked,
  supply_locked / circ_supply AS locked_vs_circulating_ratio
FROM
  circ_supply c
  INNER JOIN supply_locked v ON c.datex = v.datex
ORDER BY
  1 DESC