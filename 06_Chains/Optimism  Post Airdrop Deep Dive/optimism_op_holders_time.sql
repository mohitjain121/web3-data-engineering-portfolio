/* Description: Calculate the number of holders and holder change over time for a given token. */

WITH addresses AS (
  SELECT "to" AS adr
  FROM erc20."ERC20_evt_Transfer" tr
  WHERE contract_address = '/x0000000000'
),
transfers AS (
  SELECT 
    DAY,
    address,
    token_address,
    SUM(amount) AS amount -- Net inflow or outflow per day

  FROM (
    SELECT 
      date_trunc('day', evt_block_time) AS DAY,
      "to" AS address,
      tr.contract_address AS token_address,
      value AS amount
    FROM 
      erc20."ERC20_evt_Transfer" tr
    WHERE 
      contract_address = '\x4200000000000000000000000000000000000042'

    UNION ALL 
    SELECT 
      date_trunc('day', evt_block_time) AS DAY,
      "from" AS address,
      tr.contract_address AS token_address, 
      -value AS amount
    FROM 
      erc20."ERC20_evt_Transfer" tr
    WHERE 
      contract_address = '\x4200000000000000000000000000000000000042' --Token address
  ) t
  GROUP BY 1, 2, 3
),
balances_with_gap_days AS (
  SELECT 
    t.day,
    address,
    SUM(amount) OVER (PARTITION BY address ORDER BY t.day) AS balance, -- balance per day with a transfer
    LEAD(DAY, 1, NOW()) OVER (PARTITION BY address ORDER BY t.day) AS next_day -- the day after a day with a transfer

  FROM 
    transfers t
),
days AS (
  SELECT 
    generate_series('2016-01-20'::TIMESTAMP, date_trunc('day', NOW()), '1 day') AS DAY -- Generate all days since the first contract
),
balance_all_days AS (
  SELECT 
    d.day,
    address,
    SUM(balance / 10^0) AS balance
  FROM 
    balances_with_gap_days b
  INNER JOIN 
    days d ON b.day <= d.day AND d.day < b.next_day -- Yields an observation for every day after the first transfer until the next day with transfer
  GROUP BY 1, 2
  ORDER BY 1, 2
),
total_view AS (
  SELECT 
    b.day AS "Date",
    COUNT(address) AS "Holders",
    COUNT(address) - LAG(COUNT(address)) OVER (ORDER BY b.day) AS CHANGE
  FROM 
    balance_all_days b
  WHERE 
    balance > 0
  GROUP BY 1
  ORDER BY 1 DESC
)
SELECT * 
FROM 
  total_view 
WHERE 
  "Date" > DATE '2022-05-29';