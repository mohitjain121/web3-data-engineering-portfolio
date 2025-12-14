/* Description: Count wallets by number of vaults invested */
WITH ytokens AS (
  SELECT
    *
  FROM yearn."yearn_all_vaults" y
),

vault_invested AS (
  SELECT
    CONCAT('<a href="https://etherscan.io/address/0', SUBSTRING(address::text, 2), '" target="_blank" >', address, '</a>') AS "wallet",
    "vault_array",
    cardinality("vault_array") AS "count_of_vaults"
  FROM (
    SELECT 
      address,
      ARRAY_AGG(DISTINCT vaults::TEXT) AS "vault_array"
    FROM (
      SELECT
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
    GROUP BY 1
    WHERE address NOT IN 
      ('\x0000000000000000000000000000000000000000',
      '\x0000000000000000000000000000000000000001',
      '\x000000000000000000000000000000000000dead')
    GROUP BY 1
  )
  ORDER BY 3 DESC
)

SELECT 
  COUNT("wallet") AS "count_of_wallets",
  SUM(CASE WHEN "count_of_vaults" = 1 THEN 1 ELSE 0 END) AS "1_vault",
  SUM(CASE WHEN "count_of_vaults" >= 2 AND "count_of_vaults" < 5 THEN 1 ELSE 0 END) AS "2 - 5_vaults",
  SUM(CASE WHEN "count_of_vaults" >= 5 AND "count_of_vaults" < 10 THEN 1 ELSE 0 END) AS "5 - 10_vaults",
  SUM(CASE WHEN "count_of_vaults" >= 10 AND "count_of_vaults" < 25 THEN 1 ELSE 0 END) AS "10 - 25_vaults",
  SUM(CASE WHEN "count_of_vaults" >= 25 AND "count_of_vaults" < 50 THEN 1 ELSE 0 END) AS "25 - 50_vaults",
  SUM(CASE WHEN "count_of_vaults" >= 50 THEN 1 ELSE 0 END) AS ">50_vaults"
FROM vault_invested