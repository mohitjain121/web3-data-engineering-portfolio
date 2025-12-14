/* Description: Calculate correlation metrics for a given contract address. 

Vault Correlation 
Steps to follow:-

On top of the dashboard, input the contract address of the vault whose correlated vaults (by count of invested users) you want to find and apply the parameters
The table will refresh with the list of vaults the users of our selected vault have also invested in.
The motive of the subsequent queries are to find basket of vaults which are most correlated to each other.


*/

WITH ytokens AS (
  SELECT 
    *
  FROM 
    yearn."yearn_all_vaults" y
),

erc20_transfers AS (
  SELECT 
    t."contract_address" AS contract, 
    CONCAT(y.ytoken, ' ', y.tag) AS vault,
    t."from" AS address
  FROM 
    erc20."ERC20_evt_Transfer" t
    INNER JOIN ytokens y
    ON t."contract_address" = y.contract_address
  UNION
  SELECT 
    t."contract_address" AS contract, 
    CONCAT(y.ytoken, ' ', y.tag) AS vault,
    t."to" AS address
  FROM 
    erc20."ERC20_evt_Transfer" t
    INNER JOIN ytokens y
    ON t."contract_address" = y.contract_address
),

contract_users AS (
  SELECT 
    contract,
    vault,
    COUNT(DISTINCT address) AS "Correlated Users (Count)"
  FROM 
    erc20_transfers
  WHERE 
    address NOT IN (
      '\x0000000000000000000000000000000000000000',
      '\x0000000000000000000000000000000000000001',
      '\x000000000000000000000000000000000000dead'
    )
    AND address IN (
      SELECT 
        t."from" AS address
      FROM 
        erc20."ERC20_evt_Transfer" t
        INNER JOIN ytokens y
        ON t."contract_address" = y.contract_address
      WHERE 
        t.contract_address = CONCAT('\x', substring('{{Contract Address}}' from 3))::bytea
    )
  GROUP BY 
    1, 2
  ORDER BY 
    3 DESC
),

correlation AS (
  SELECT 
    contract,
    vault,
    "Correlated Users (Count)",
    FIRST_VALUE("Correlated Users (Count)") 
    OVER (
      ORDER BY "Correlated Users (Count)" DESC
    ) AS first_value
  FROM 
    contract_users
)

SELECT 
  CONCAT('<a href="https://etherscan.io/address/0', SUBSTRING("Contract"::text, 2), '" target="_blank" >', "Contract", '</a>') AS "Contract",
  "Correlated Vaults (DESC)",
  "Correlated Users (Count)",
  CAST("Correlated Users (Count)" AS FLOAT)/CAST(first_value AS FLOAT)*100 AS "% Correlation"
FROM 
  correlation
GROUP BY 
  1, 2, 3, 4
ORDER BY 
  3 DESC