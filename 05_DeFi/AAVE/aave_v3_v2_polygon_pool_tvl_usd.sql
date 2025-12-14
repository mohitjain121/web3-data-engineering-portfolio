/* Description: Calculate AAVE v2 and v3 TVL */
WITH

daily_prices AS (
  -- Get avg price on the last hour of the day (approximate end-of-day price in USD)
  SELECT
        p.symbol
      , p.minute::date AS day
      , p.contract_address
      , p.decimals
      , avg(p.price) AS price

  FROM prices.usd AS p
  WHERE date_part('hour', p.minute) = 23
  GROUP BY 1, 2, 3, 4
),

v2_tvl AS (
  WITH
    -- Get all transactions for AAVE v2
    transactions AS (
      SELECT
            t.evt_block_time AS ts
          , t.reserve AS erc20_token_address
          , t.amount
          , 'deposit' AS trans_type

      FROM aave_v2."LendingPool_evt_Deposit" AS t

      UNION ALL

      SELECT
            t.evt_block_time AS ts
          , t.reserve AS erc20_token_address
          , t.amount
          , 'withdraw' AS trans_type

      FROM aave_v2."LendingPool_evt_Withdraw" AS t

      UNION ALL

      SELECT
            t.evt_block_time AS ts
          , t.reserve AS erc20_token_address
          , t.amount
          , 'borrow' AS trans_type

      FROM aave_v2."LendingPool_evt_Borrow" AS t

      UNION ALL

      SELECT
            t.evt_block_time AS ts
          , t.reserve AS erc20_token_address
          , t.amount
          , 'repay' AS trans_type

      FROM aave_v2."LendingPool_evt_Repay" AS t

      UNION ALL

      SELECT
            t.evt_block_time AS ts
          , t."collateralAsset" AS erc20_token_address
          , t."liquidatedCollateralAmount" AS amount
          , 'liquidate_collateral' AS trans_type

      FROM aave_v2."LendingPool_evt_LiquidationCall" AS t

      UNION ALL

      SELECT
            t.evt_block_time AS ts
          , t."debtAsset" AS erc20_token_address
          , t."debtToCover" AS amount
          , 'repay_via_liquidation' AS trans_type

      FROM aave_v2."LendingPool_evt_LiquidationCall" AS t
    ),

    -- Aggregate transactions by day and asset
    daily_agg_per_asset_per_trans_type AS (
      SELECT
            t.ts::date AS day
          , t.erc20_token_address
          , t.trans_type
          , sum(t.amount) AS amount

      FROM transactions AS t
      GROUP BY 1, 2, 3
    ),

    -- Calculate net supply for each asset
    daily_net_supply_per_asset AS (
      SELECT
            day
          , erc20_token_address
          , sum(CASE WHEN trans_type = 'deposit' THEN amount
                     WHEN trans_type = 'withdraw' THEN -amount
                     WHEN trans_type = 'borrow' THEN -amount
                     WHEN trans_type = 'repay' THEN amount
                     WHEN trans_type = 'liquidate_collateral' THEN -amount
                     WHEN trans_type = 'repay_via_liquidation' THEN amount
                     END) AS net_supply

      FROM daily_agg_per_asset_per_trans_type
      GROUP BY 1, 2
    ),

    -- Calculate cumulative supply for each asset
    daily_cumulative_supply_per_asset AS (
      SELECT
            day
          , erc20_token_address
          , sum(net_supply) OVER (PARTITION BY erc20_token_address
                                  ORDER BY day
                                  ROWS BETWEEN UNBOUNDED PRECEDING
                                             AND CURRENT ROW) AS supply

      FROM daily_net_supply_per_asset
    ),

    -- Join daily prices to calculate TVL in USD
    daily_cumulative_supply_per_asset_usd AS (
      SELECT
            s.day
          , p.symbol
          , s.supply / 10 ^ p.decimals AS token_supply
          , p.price
          , s.supply / 10 ^ p.decimals * p.price AS total_value

      FROM daily_cumulative_supply_per_asset AS s
          LEFT JOIN daily_prices AS p
              ON p.contract_address = s.erc20_token_address
              AND p.day = s.day
    ),

    -- Calculate total TVL for each day
    daily_tvl AS (
      SELECT
            day
          , sum(total_value) AS total_value

      FROM daily_cumulative_supply_per_asset_usd
      GROUP BY 1
    ),

    -- Quality assurance
    qa AS (
      SELECT
            count(*)
          , count(price)

      FROM daily_cumulative_supply_per_asset_usd
    )

  SELECT *
  FROM daily_cumulative_supply_per_asset_usd
),

v3_tvl AS (
  WITH
    -- Get all transactions for AAVE v3
    transactions AS (
      SELECT
            t.evt_block_time AS ts
          , t.reserve AS erc20_token_address
          , t.amount
          , 'deposit' AS trans_type

      FROM aave_v3."Pool_evt_Supply" AS t

      UNION ALL

      SELECT
            t.evt_block_time AS ts
          , t.reserve AS erc20_token_address
          , t.amount
          , 'withdraw' AS trans_type

      FROM aave_v3."Pool_evt_Withdraw" AS t

      UNION ALL

      SELECT
            t.evt_block_time AS ts
          , t.reserve AS erc20_token_address
          , t.amount
          , 'borrow' AS trans_type

      FROM aave_v3."Pool_evt_Borrow" AS t

      UNION ALL

      SELECT
            t.evt_block_time AS ts
          , t.reserve AS erc20_token_address
          , t.amount
          , 'repay' AS trans_type

      FROM aave_v3."Pool_evt_Repay" AS t

      UNION ALL

      SELECT
            t.evt_block_time AS ts
          , t."collateralAsset" AS erc20_token_address
          , t."liquidatedCollateralAmount" AS amount
          , 'liquidate_collateral' AS trans_type

      FROM aave_v3."Pool_evt_LiquidationCall" AS t

      UNION ALL

      SELECT
            t.evt_block_time AS ts
          , t."debtAsset" AS erc20_token_address
          , t."debtToCover" AS amount
          , 'repay_via_liquidation' AS trans_type

      FROM aave_v3."Pool_evt_LiquidationCall" AS t
    ),

    -- Aggregate transactions by day and asset
    daily_agg_per_asset_per_trans_type AS (
      SELECT
            t.ts::date AS day
          , t.erc20_token_address
          , t.trans_type
          , sum(t.amount) AS amount

      FROM transactions AS t
      GROUP BY 1, 2, 3
    ),

    -- Calculate net supply for each asset
    daily_net_supply_per_asset AS (
      SELECT
            day
          , erc20_token_address
          , sum(CASE WHEN trans_type = 'deposit' THEN amount
                     WHEN trans_type = 'withdraw' THEN -amount
                     WHEN trans_type = 'borrow' THEN -amount
                     WHEN trans_type = 'repay' THEN amount
                     WHEN trans_type = 'liquidate_collateral' THEN -amount
                     WHEN trans_type = 'repay_via_liquidation' THEN amount
                     END) AS net_supply

      FROM daily_agg_per_asset_per_trans_type
      GROUP BY 1, 2
    ),

    -- Calculate cumulative supply for each asset
    daily_cumulative_supply_per_asset AS (
      SELECT
            day
          , erc20_token_address
          , sum(net_supply) OVER (PARTITION BY erc20_token_address
                                  ORDER BY day
                                  ROWS BETWEEN UNBOUNDED PRECEDING
                                             AND CURRENT ROW) AS supply

      FROM daily_net_supply_per_asset
    ),

    -- Join daily prices to calculate TVL in USD
    daily_cumulative_supply_per_asset_usd AS (
      SELECT
            s.day
          , p.symbol
          , s.supply / 10 ^ p.decimals AS token_supply
          , p.price
          , s.supply / 10 ^ p.decimals * p.price AS total_value

      FROM daily_cumulative_supply_per_asset AS s
          LEFT JOIN daily_prices AS p
              ON p.contract_address = s.erc20_token_address
              AND p.day = s.day
    ),

    -- Calculate total TVL for each day
    daily_tvl AS (
      SELECT
            day
          , sum(total_value) AS total_value

      FROM daily_cumulative_supply_per_asset_usd
      GROUP BY 1
    ),

    -- Quality assurance
    qa AS (
      SELECT
            count(*)
          , count(price)

      FROM daily_cumulative_supply_per_asset_usd
    )

  SELECT *
  FROM daily_cumulative_supply_per_asset_usd
),

combined AS (
  SELECT
        COALESCE(v2.day, v3.day) AS day
      , COALESCE(v2.symbol, v3.symbol) AS symbol
      , COALESCE(v2.total_value, 0) AS v2_value_usd
      , COALESCE(v3.total_value, 0) AS v3_value_usd

  FROM v2_tvl AS v2
      FULL JOIN v3_tvl AS v3
          ON v2.symbol = v3.symbol
          AND v2.day = v3.day
),

output_prep AS (
  SELECT
        day
      , LAST_VALUE(day) OVER (ORDER BY day
                              ROWS BETWEEN UNBOUNDED PRECEDING
                                       AND UNBOUNDED FOLLOWING) AS latest_day
      , symbol
      , v2_value_usd
      , v3_value_usd

  FROM combined
  WHERE symbol IS NOT NULL
),

-- Get the latest day for each symbol
latest_day AS (
  SELECT
        symbol
      , MAX(day) AS latest_day

  FROM output_prep
  GROUP BY 1
)

SELECT
      symbol
    , v2_value_usd
    , v3_value_usd

FROM output_prep
WHERE day = (SELECT latest_day FROM latest_day WHERE symbol = output_prep.symbol)
ORDER BY v2_value_usd + v3_value_usd DESC