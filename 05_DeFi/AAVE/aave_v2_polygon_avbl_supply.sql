/* Description: Aave V3 transaction aggregation and analysis query. */

WITH 
  -- Get all Aave V3 transactions
  getAllV3Transaction AS (
    SELECT 
      "evt_block_time" AS "date",
      'supply' AS "action",
      "amount" AS "token_amount",
      "reserve" AS "reserve"
    FROM 
      aave_v2."LendingPool_evt_Deposit"
    UNION ALL
    SELECT 
      "evt_block_time" AS "date",
      'withdraw' AS "action",
      "amount" AS "token_amount",
      "reserve" AS "reserve"
    FROM 
      aave_v2."LendingPool_evt_Withdraw"
    UNION ALL
    SELECT 
      "evt_block_time" AS "date",
      'borrow' AS "action",
      "amount" AS "token_amount",
      "reserve" AS "reserve"
    FROM 
      aave_v2."LendingPool_evt_Borrow"
    UNION ALL
    SELECT 
      "evt_block_time" AS "date",
      'repay' AS "action",
      "amount" AS "token_amount",
      "reserve" AS "reserve"
    FROM 
      aave_v2."LendingPool_evt_Repay"
    UNION ALL
    SELECT 
      "evt_block_time" AS "date",
      'liquidate' AS "action",
      "liquidatedCollateralAmount" AS "token_amount",
      "collateralAsset" AS "reserve"
    FROM 
      aave_v2."LendingPool_evt_LiquidationCall"
    UNION ALL
    SELECT 
      "evt_block_time" AS "date",
      'liquidate_repay' AS "action",
      "debtToCover" AS "token_amount",
      "debtAsset" AS "reserve"
    FROM 
      aave_v2."LendingPool_evt_LiquidationCall"
  ),
  
  -- Generate and aggregate Aave data
  generateAndAggregateAaveData AS (
    SELECT 
      "dummy_date" AS "date",
      "action",
      "reserve",
      "symbol",
      "token_amount" / POWER(10, "decimals") AS "token_amount"
    FROM (
      SELECT DISTINCT 
        "action",
        "dummy_date",
        "reserve",
        0::numeric AS "token_amount"
      FROM 
        getAllV3Transaction
      CROSS JOIN 
        generate_series('2022-03-01', NOW(), '1 day') AS "dummy_date"
    )
    UNION ALL
    SELECT 
      "action",
      "evt_block_time" AS "date",
      "reserve",
      "token_amount"
    FROM 
      getAllV3Transaction
  ),
  
  -- Get token prices daily
  getTokenPricesDaily AS (
    SELECT 
      DATE_TRUNC('day', "minute") AS "date",
      "symbol",
      AVG("price") AS "avg_price"
    FROM 
      prices."usd"
    WHERE 
      "contract_address" IN (SELECT DISTINCT "reserve" FROM getAllV3Transaction)
      AND "minute" > '2022-03-01'
    GROUP BY 
      1, 2
  ),
  
  -- Get Aave daily data
  getAaveDailyData AS (
    SELECT 
      c."date",
      c."symbol",
      COALESCE(SUM("token_amount") FILTER (WHERE "action" = 'withdraw'), 0) AS "withdraw",
      COALESCE(SUM("token_amount") FILTER (WHERE "action" = 'supply'), 0) AS "supply",
      COALESCE(SUM("token_amount") FILTER (WHERE "action" = 'borrow'), 0) AS "borrow",
      COALESCE(SUM("token_amount") FILTER (WHERE "action" = 'repay'), 0) AS "repay",
      COALESCE(SUM("token_amount") FILTER (WHERE "action" = 'liquidate'), 0) AS "liquidate",
      COALESCE(SUM("token_amount") FILTER (WHERE "action" = 'liquidate_repay'), 0) AS "liquidate_repay"
    FROM (
      SELECT 
        DATE_TRUNC('day', a."date") AS "date",
        "action",
        a."symbol",
        SUM("token_amount") AS "token_amount",
        SUM(SUM("token_amount")) OVER (PARTITION BY "action", a."symbol" ORDER BY DATE_TRUNC('day', a."date")) AS "cumulative_token_amount"
      FROM 
        generateAndAggregateAaveData a
      GROUP BY 
        1, 2, 3
    ) x
    GROUP BY 
      1, 2
  ),
  
  -- Calculate overall pool balance and borrowed USD
  getOverallData AS (
    SELECT 
      *,
      SUM("pool_balance_usd") OVER (PARTITION BY "date" ORDER BY "date") AS "overall_pool_balance_usd",
      SUM("borrowed_usd") OVER (PARTITION BY "date" ORDER BY "date") AS "overall_borrowed_usd",
      SUM("total_reserve_usd") OVER (PARTITION BY "date" ORDER BY "date") AS "overall_reserve_usd",
      SUM("total_reserve_usd") OVER (PARTITION BY "date" ORDER BY "date") AS "overall_supply_usd"
    FROM (
      SELECT 
        *,
        "total_reserve_usd" - "borrowed_usd" AS "pool_balance_usd",
        "borrowed_usd" / NULLIF("total_reserve_usd", 0) AS "utilization"
      FROM (
        SELECT 
          *,
          "supply_usd" - "withdraw_usd" - "liquidate_usd" AS "total_reserve_usd",
          "borrow_usd" - "repay_usd" - "liquidate_repay_usd" AS "borrowed_usd"
        FROM 
          getAaveDailyData
      ) x
      ORDER BY 
        1 DESC
    ) p
    ORDER BY 
      1 DESC
  )

SELECT * FROM getOverallData;