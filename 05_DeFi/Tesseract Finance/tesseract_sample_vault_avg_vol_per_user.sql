/* Description: Calculate average deposit and withdrawal per user for a specific contract */
SELECT 
  x.day_of_deposit,
  deposit / users1 AS "AVG Deposit/User",
  withdrawal / users2 AS "AVG Withdrawal/User"
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
    1 DESC
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
    1 DESC
) y
ON 
  x.day_of_deposit = y.day_of_deposit
GROUP BY 
  1, 2, 3
ORDER BY 
  1 DESC;