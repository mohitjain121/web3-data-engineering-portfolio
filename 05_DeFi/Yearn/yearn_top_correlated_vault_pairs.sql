/* Description: Extract top 100 most frequent vault pairs from yearn_all_vaults */
WITH 
  ytokens AS (
    SELECT 
      *
    FROM 
      yearn."yearn_all_vaults" y
  ),
  
  order_pairs AS (
    SELECT 
      (x.vault, y.vault) AS vault, 
      x."to" 
    FROM 
      (
        SELECT DISTINCT 
          CONCAT(p.ytoken, ' ', p.tag) AS vault, 
          "to"
        FROM 
          erc20."ERC20_evt_Transfer" m
          INNER JOIN ytokens p ON m.contract_address = p.contract_address
      ) x
      JOIN 
      (
        SELECT DISTINCT 
          CONCAT(p.ytoken, ' ', p.tag) AS vault, 
          "to"
        FROM 
          erc20."ERC20_evt_Transfer" n
          INNER JOIN ytokens p ON n.contract_address = p.contract_address
      ) y
      ON x."to" = y."to"
      AND x.vault != y.vault
      AND x.vault < y.vault
  )
  
SELECT DISTINCT 
  vault, 
  COUNT(*) AS "Frequency" 
FROM 
  order_pairs
GROUP BY 
  1
ORDER BY 
  2 DESC
LIMIT 100;