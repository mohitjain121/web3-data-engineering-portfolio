/* Description: Calculate the average time difference between deposit and withdrawal transactions. */

WITH
  deptime AS (
    SELECT 
      account_keys[0] AS address, 
      MIN(`block_time`) AS dep_time
    FROM 
      `solana`.`transactions`
    WHERE 
      array_contains(account_keys, 'EhhTKczWMGQt46ynNeRX1WfeagwwJd7ufHvCDjRxjo5Q')
      AND (CAST(log_messages AS STRING) LIKE '%Instruction: Deposit%')
      -- AND block_time > NOW() - INTERVAL '90 DAYS'
      -- OR CAST(log_messages AS STRING) LIKE '%Instruction: DepositV2%')
    GROUP BY 
      1
  ),
  withtime AS (
    SELECT 
      account_keys[0] AS address, 
      MIN(`block_time`) AS with_time
    FROM 
      `solana`.`transactions`
    WHERE 
      array_contains(account_keys, 'EhhTKczWMGQt46ynNeRX1WfeagwwJd7ufHvCDjRxjo5Q')
      AND (CAST(log_messages AS STRING) LIKE '%Instruction: Withdraw%')
      -- AND block_time > NOW() - INTERVAL '90 DAYS'
      -- OR CAST(log_messages AS STRING) LIKE '%Instruction: WithdrawV2%')
    GROUP BY 
      1
  ),
  avgtime AS (
    SELECT 
      d.address, 
      DATE_PART('DAY', COALESCE(with_time, NOW()) - dep_time) AS time_diff 
    FROM 
      deptime d 
    LEFT JOIN 
      withtime w ON d.address = w.address
    GROUP BY 
      1, 2
  )

SELECT 
  AVG(time_diff) AS avg_time 
FROM 
  avgtime