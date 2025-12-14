/* Description: Calculate the average time difference between deposit and withdrawal transactions for a specific Solana account. */

WITH
  deptime AS (
    SELECT 
      account_keys[0] AS address, 
      MIN(`block_time`) AS dep_time
    FROM 
      `solana`.`transactions`
    WHERE 
      array_contains(account_keys, '675kPX9MHTjS2zt1qfr1NYHuzeLXfQM9H24wFSUt1Mp8')
      AND (CAST(log_messages AS STRING) LIKE '%Instruction: Deposit%')
      AND block_date BETWEEN '2022-01-01' AND '2022-01-31'
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
      array_contains(account_keys, '675kPX9MHTjS2zt1qfr1NYHuzeLXfQM9H24wFSUt1Mp8')
      AND (CAST(log_messages AS STRING) LIKE '%Instruction: Withdraw%')
      AND block_date > '2022-01-01'
    GROUP BY 
      1
  ),
  avgtime AS (
    SELECT 
      d.address, 
      DATE_PART('DAY', COALESCE(with_time, CURRENT_TIMESTAMP)) - dep_time AS time_diff 
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