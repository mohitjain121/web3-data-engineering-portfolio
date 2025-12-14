/* Description: Extract daily vault data from ERC20 transfer events. */

WITH ytokens AS (
  SELECT 
    *
  FROM 
    yearn."yearn_all_vaults" y
)

SELECT 
  datex, 
  COUNT(DISTINCT address), 
  vault
FROM 
  (
    SELECT 
      date_trunc('DAY', evt_block_time) AS datex,
      CONCAT(y.ytoken, ' ', y.tag) AS vault,
      t."from" AS address
    FROM 
      erc20."ERC20_evt_Transfer" t
      INNER JOIN ytokens y
      ON t."contract_address" = y.contract_address
    UNION
    SELECT 
      date_trunc('DAY', evt_block_time) AS datex,
      CONCAT(y.ytoken, ' ', y.tag) AS vault,
      t."to" AS address
    FROM 
      erc20."ERC20_evt_Transfer" t
      INNER JOIN ytokens y
      ON t."contract_address" = y.contract_address
  ) c
WHERE 
  address NOT IN 
  (
    '\x0000000000000000000000000000000000000000', 
    '\x0000000000000000000000000000000000000001',
    '\x000000000000000000000000000000000000dead'
  )
GROUP BY 
  1, 3