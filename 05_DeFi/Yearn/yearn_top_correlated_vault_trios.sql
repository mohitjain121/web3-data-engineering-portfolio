/* Description: Extract top 100 vault pairs with highest frequency of transfers. */

WITH ytokens AS (
  SELECT 
    *
  FROM 
    yearn."yearn_all_vaults" y
),

order_pairs AS (
  SELECT 
    (x.vault, y.vault, z.vault) AS vault, 
    x."to" 
  FROM 
    (
      SELECT 
        DISTINCT CONCAT(p.ytoken, ' ', p.tag) AS vault, 
        "to"
      FROM 
        erc20."ERC20_evt_Transfer" m
        INNER JOIN ytokens p ON m.contract_address = p.contract_address
    ) x
    JOIN 
    (
      SELECT 
        DISTINCT CONCAT(p.ytoken, ' ', p.tag) AS vault, 
        "to"
      FROM 
        erc20."ERC20_evt_Transfer" n
        INNER JOIN ytokens p ON n.contract_address = p.contract_address
    ) y 
    ON x."to" = y."to" 
    AND x.vault != y.vault 
    AND x.vault < y.vault
    JOIN 
    (
      SELECT 
        DISTINCT CONCAT(p.ytoken, ' ', p.tag) AS vault, 
        "to"
      FROM 
        erc20."ERC20_evt_Transfer" o
        INNER JOIN ytokens p ON o.contract_address = p.contract_address
    ) z
    ON x."to" = z."to" 
    AND y."to" = z."to"
    AND x.vault != z.vault 
    AND y.vault != z.vault
    AND y.vault < z.vault 
    AND x.vault < z.vault
),

-- Extract top 100 vault pairs with highest frequency of transfers
top_vault_pairs AS (
  SELECT 
    DISTINCT vault,
    COUNT(*) AS "Frequency" 
  FROM 
    order_pairs
  GROUP BY 
    1
  ORDER BY 
    2 DESC
  LIMIT 100
)

SELECT * FROM top_vault_pairs;