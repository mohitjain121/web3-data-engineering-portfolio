/* Description: Aggregate Aave V3 transaction data and calculate daily metrics */

WITH 
  aave_v3_supply AS (
    SELECT 
      "evt_block_time" AS "date",
      'supply' AS "action",
      "amount" AS "token_amount",
      "reserve" AS "reserve",
      "evt_tx_hash" AS "evt_tx_hash"
    FROM 
      aave_v3."Pool_evt_Supply"
  ),
  
  aave_v3_withdraw AS (
    SELECT 
      "evt_block_time" AS "date",
      'withdraw' AS "action",
      "amount" AS "token_amount",
      "reserve" AS "reserve",
      "evt_tx_hash" AS "evt_tx_hash"
    FROM 
      aave_v3."Pool_evt_Withdraw"
  ),
  
  aave_v3_borrow AS (
    SELECT 
      "evt_block_time" AS "date",
      'borrow' AS "action",
      "amount" AS "token_amount",
      "reserve" AS "reserve",
      "evt_tx_hash" AS "evt_tx_hash"
    FROM 
      aave_v3."Pool_evt_Borrow"
  ),
  
  aave_v3_repay AS (
    SELECT 
      "evt_block_time" AS "date",
      'repay' AS "action",
      "amount" AS "token_amount",
      "reserve" AS "reserve",
      "evt_tx_hash" AS "evt_tx_hash"
    FROM 
      aave_v3."Pool_evt_Repay"
  ),
  
  getAllV3Transaction AS (
    SELECT * FROM aave_v3_supply
    UNION ALL
    SELECT * FROM aave_v3_withdraw
    UNION ALL
    SELECT * FROM aave_v3_borrow
    UNION ALL
    SELECT * FROM aave_v3_repay
  ),
  
  generateAndAggregateAaveData AS (
    SELECT 
      "dummy_date" AS "date",
      "action",
      "reserve",
      "symbol",
      "token_amount" / POWER(10, "decimals") AS "token_amount"
    FROM (
      (SELECT DISTINCT 
        "action",
        "dummy_date",
        "reserve",
        0::numeric AS "token_amount"
      FROM 
        getAllV3Transaction
      CROSS JOIN 
        generate_series('2022-03-12', NOW(), '1 day') AS "dummy_date")
      UNION ALL
      SELECT 
        "action",
        "evt_block_time",
        "reserve",
        "token_amount"
      FROM 
        getAllV3Transaction
    ) g
    LEFT JOIN 
      erc20."tokens" et ON ("reserve" = et."contract_address")
  ),
  
  getTokenPricesDaily AS (
    SELECT 
      DATE_TRUNC('day', "minute") AS "date",
      "symbol",
      AVG("price") AS "avg_price"
    FROM 
      prices."usd"
    WHERE 
      "contract_address" IN (SELECT DISTINCT "reserve" FROM getAllV3Transaction)
      AND "minute" > '2022-03-12'
    GROUP BY 
      1, 2
  ),
  
  getAaveDailyData AS (
    SELECT 
      c."date",
      c."symbol",
      COALESCE(SUM("cumulative_token_amount") FILTER (WHERE "action" = 'withdraw'), 0) AS "withdraw",
      COALESCE(SUM("cumulative_token_amount") FILTER (WHERE "action" = 'supply'), 0) AS "supply",
      COALESCE(SUM("cumulative_token_amount") FILTER (WHERE "action" = 'borrow'), 0) AS "borrow",
      COALESCE(SUM("cumulative_token_amount") FILTER (WHERE "action" = 'repay'), 0) AS "repay"
    FROM (
      SELECT 
        "date",
        "symbol",
        "action",
        "token_amount",
        SUM("token_amount") OVER (
          PARTITION BY "action", "symbol" 
          ORDER BY DATE_TRUNC('day', "date")
        ) AS "cumulative_token_amount"
      FROM (
        SELECT 
          DATE_TRUNC('day', a."date") AS "date",
          "action",
          a."symbol",
          "token_amount",
          SUM("token_amount") OVER (
            PARTITION BY "action", a."symbol" 
            ORDER BY DATE_TRUNC('day', a."date")
          ) AS "cumulative_token_amount"
        FROM 
          generateAndAggregateAaveData a
        GROUP BY 
          1, 2, 3
      ) x
      GROUP BY 
        1, 2
    ) c
    LEFT JOIN 
      getTokenPricesDaily b ON (DATE_TRUNC('day', c."date") = b."date" AND UPPER(c."symbol") = b."symbol")
  )
  
SELECT 
  *,
  SUM("pool_balance_usd") OVER (
    PARTITION BY "date" 
    ORDER BY "date"
  ) AS "overall_pool_balance_usd",
  SUM("borrowed_usd") OVER (
    PARTITION BY "date" 
    ORDER BY "date"
  ) AS "overall_borrowed_usd",
  SUM("total_reserve_usd") OVER (
    PARTITION BY "date" 
    ORDER BY "date"
  ) AS "overall_reserve_usd",
  SUM("total_reserve_usd") OVER (
    PARTITION BY "date" 
    ORDER BY "date"
  ) AS "overall_supply_usd"
FROM (
  SELECT 
    *,
    "total_reserve_usd" - "borrowed_usd" AS "pool_balance_usd",
    "borrowed_usd" / NULLIF("total_reserve_usd", 0) AS "utilization"
  FROM (
    SELECT 
      *,
      "supply_usd" - "withdraw_usd" AS "total_reserve_usd",
      "borrow_usd" - "repay_usd" AS "borrowed_usd"
    FROM 
      getAaveDailyData
  ) x
  ORDER BY 
    1 DESC
) p
ORDER BY 
  1 DESC