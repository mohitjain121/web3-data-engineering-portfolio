/* Description: Calculate vault value by subtracting cumulative withdrawals from cumulative deposits. */
SELECT 
  p.day_of_deposit, 
  "Cumulative Deposits" - "Cumulative Withdrawals" AS "Vault Value", 
  "Cumulative Deposits", 
  "Cumulative Withdrawals"
FROM (
  SELECT 
    x.day_of_deposit, 
    SUM(SUM(deposit) - SUM(withdrawal)) OVER (ORDER BY x.day_of_deposit ASC) AS "Vault Value", 
    SUM(SUM(deposit)) OVER (ORDER BY x.day_of_deposit ASC) AS "Cumulative Deposits", 
    SUM(SUM(withdrawal)) OVER (ORDER BY x.day_of_deposit ASC) AS "Cumulative Withdrawals"
  FROM (
    SELECT 
      date_trunc('DAY', evt_block_time) AS day_of_deposit, 
      SUM("value" / 1e18) AS deposit, 
      COUNT("to") AS users1
    FROM 
      erc20."ERC20_evt_Transfer" 
    WHERE 
      "from" = '\x0000000000000000000000000000000000000000' 
      AND "contract_address" = '\xBC85571Cd19303FF45A37bAF9bf446C48B1F7671' --ATriCreypto
    GROUP BY 
      1 
    ORDER BY 
      1 ASC
  ) x 
  FULL JOIN (
    SELECT 
      date_trunc('DAY', evt_block_time) AS day_of_deposit, 
      SUM("value" / 1e18) AS withdrawal, 
      COUNT("from") AS users2
    FROM 
      erc20."ERC20_evt_Transfer"
    WHERE 
      "to" = '\x0000000000000000000000000000000000000000' 
      AND "contract_address" = '\xBC85571Cd19303FF45A37bAF9bf446C48B1F7671' --ATriCreypto
    GROUP BY 
      1 
    ORDER BY 
      1 ASC
  ) y 
  ON 
    x.day_of_deposit = y.day_of_deposit
  GROUP BY 
    1 
  ORDER BY 
    1 ASC
) p