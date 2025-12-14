/* Description: Calculate the average time difference between deposit and withdrawal for a specific wallet address. */
SELECT 
  AVG(time_diff) AS "avg_atricrypto_vault_deposit_time"
FROM 
  (
    SELECT 
      x.address, 
      DATE_PART('DAY', COALESCE(with_time, NOW()) - dep_time) AS time_diff
    FROM 
      (
        SELECT 
          "from" AS address, 
          MIN(evt_block_time) AS dep_time
        FROM 
          erc20."ERC20_evt_Transfer"
        WHERE 
          "to" = '\xBC85571Cd19303FF45A37bAF9bf446C48B1F7671'
        GROUP BY 
          1
        ORDER BY 
          2 DESC
      ) x
      FULL JOIN 
      (
        SELECT 
          "to" AS address, 
          COALESCE(MIN(evt_block_time), NOW()) AS with_time
        FROM 
          erc20."ERC20_evt_Transfer"
        WHERE 
          "from" = '\xBC85571Cd19303FF45A37bAF9bf446C48B1F7671'
        GROUP BY 
          1
        ORDER BY 
          2 DESC
      ) y ON 
      x.address = y.address
  ) x
GROUP BY 
  1, 2