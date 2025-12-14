/* Description: Extract top 100 wallets with the most vaults from yearn_all_vaults */
WITH ytokens AS (
  SELECT 
    *
  FROM 
    yearn."yearn_all_vaults" y
)

SELECT 
  CONCAT('<a href="https://etherscan.io/address/0', SUBSTRING(address::text, 2), '" target="_blank" >', address, '</a>') AS "wallet",
  "vault_array",
  cardinality("vault_array") AS "count_of_vaults"
FROM 
  (SELECT 
    address,
    ARRAY_AGG(DISTINCT vaults::TEXT) AS "vault_array"
  FROM 
    (SELECT 
      t."from" AS address,
      CONCAT(y.ytoken, ' ', y.tag) AS vaults
    FROM 
      erc20."ERC20_evt_Transfer" t
      INNER JOIN ytokens y
      ON t."contract_address" = y.contract_address
    UNION 
      SELECT 
      t."to" AS address,
      CONCAT(y.ytoken, ' ', y.tag) AS vaults
    FROM 
      erc20."ERC20_evt_Transfer" t
      INNER JOIN ytokens y
      ON t."contract_address" = y.contract_address) m
  GROUP BY 1) c
WHERE 
  address NOT IN 
    ('\x0000000000000000000000000000000000000000',
    '\x0000000000000000000000000000000000000001',
    '\x000000000000000000000000000000000000dead')
GROUP BY 1, 2, 3
ORDER BY 3 DESC
LIMIT 100;