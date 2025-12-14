-- Description: Calculate CULT and dCULT token balances and holders
WITH 
  -- CULT token balances  
  cult_tb_received AS (
    SELECT 
      CAST("to" AS VARCHAR) AS address,  
      --COALESCE(SUM(CAST(value AS DECIMAL)),0) AS received,
      CASE 
        WHEN SUM(CAST(value AS DECIMAL)) IS NULL THEN 0
        ELSE SUM(CAST(value AS DECIMAL))
      END AS received
    FROM erc20_ethereum.evt_transfer
    WHERE CAST(contract_address AS VARCHAR) = '0xf0f9d895aca5c8678f706fb8216fa22957685a13'
    GROUP BY 1
  ),
  
  cult_tb_sent AS (
    SELECT 
      CAST("from" AS VARCHAR) AS address, 
      --COALESCE(-SUM(CAST(value AS DECIMAL)),0) AS sent,
      CASE 
        WHEN -SUM(CAST(value AS DECIMAL)) IS NULL THEN 0
        ELSE -SUM(CAST(value AS DECIMAL))
      END AS sent
    FROM erc20_ethereum.evt_transfer
    WHERE CAST(contract_address AS VARCHAR) = '0xf0f9d895aca5c8678f706fb8216fa22957685a13'
    GROUP BY 1
  ),
  
  cult_tb_received_sent AS (
    SELECT 
      r.address,
      CASE 
        WHEN r.received IS NULL THEN (CAST(0 AS DECIMAL))
        ELSE r.received
      END AS received,
      CASE 
        WHEN s.sent IS NULL THEN (CAST(0 AS DECIMAL))
        ELSE s.sent
      END AS sent
    FROM cult_tb_received AS r 
    LEFT JOIN cult_tb_sent AS s ON (r.address = s.address)
  ),
  
  cult_tb AS (
    SELECT
      address,
      CAST(SUM(received + sent) AS DOUBLE) / 1e18 AS balance1,
      SUM(received + sent) AS balance 
    FROM cult_tb_received_sent
    GROUP BY 1
  ),
  
  -- DCULT token balances 
  
  dcult_tb_received AS (
    SELECT 
      CAST("to" AS VARCHAR) AS address,  
      --COALESCE(SUM(CAST(value AS DECIMAL)),0) AS received,
      CASE 
        WHEN SUM(CAST(value AS DECIMAL)) IS NULL THEN 0
        ELSE SUM(CAST(value AS DECIMAL))
      END AS received
    FROM erc20_ethereum.evt_transfer
    WHERE CAST(contract_address AS VARCHAR) = '0x2d77b594b9bbaed03221f7c63af8c4307432daf1'
    GROUP BY 1
  ),
  
  dcult_tb_sent AS (
    SELECT 
      CAST("from" AS VARCHAR) AS address,  
      --COALESCE(-SUM(CAST(value AS DECIMAL)),0) AS sent,
      CASE 
        WHEN -SUM(CAST(value AS DECIMAL)) IS NULL THEN 0
        ELSE -SUM(CAST(value AS DECIMAL))
      END AS sent
    FROM erc20_ethereum.evt_transfer
    WHERE CAST(contract_address AS VARCHAR) = '0x2d77b594b9bbaed03221f7c63af8c4307432daf1'
    GROUP BY 1
  ),
  
  dcult_tb_received_sent AS (
    SELECT 
      r.address,
      CASE 
        WHEN r.received IS NULL THEN (CAST(0 AS DECIMAL))
        ELSE r.received
      END AS received,
      CASE 
        WHEN s.sent IS NULL THEN (CAST(0 AS DECIMAL))
        ELSE s.sent
      END AS sent
    FROM dcult_tb_received AS r 
    LEFT JOIN dcult_tb_sent AS s ON (r.address = s.address)
  ),
  
  dcult_tb AS (
    SELECT
      address,
      CAST(SUM(received + sent) AS DOUBLE) / 1e18 AS balance1,
      SUM(received + sent) AS balance 
    FROM dcult_tb_received_sent
    GROUP BY 1
  ),
  
  temp AS (
    SELECT 
      COALESCE(ctb.address, dtb.address) AS address,
      COALESCE(ctb.balance, 0) AS cult,
      COALESCE(dtb.balance, 0) AS dcult,
      COALESCE(ctb.balance, 0) + COALESCE(dtb.balance, 0) AS total_cult
    FROM cult_tb AS ctb
    FULL OUTER JOIN dcult_tb AS dtb ON ctb.address = dtb.address
    WHERE ctb.address <> '0x0000000000000000000000000000000000000000'
  )

SELECT 
  Count(Distinct address) FILTER (WHERE total_cult > 0) AS "CULT & dCULT holders",
  Count(Distinct address) FILTER (WHERE cult > 0) AS "CULT holders",
  Count(Distinct address) FILTER (WHERE dcult > 0) AS "CULT stakers"
FROM temp