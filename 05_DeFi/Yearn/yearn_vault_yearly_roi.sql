/* Description: Calculate yearly ROI for Yearn vaults based on historical price data. */

WITH 
  -- Get distinct vault prices per share from multiple sources
  vault_price_per_share AS (
    SELECT 
      * 
    FROM (
      SELECT DISTINCT
        p.contract_address,
        ROUND(FIRST_VALUE(p.output_0 / 10 ^ (y.decimals)) OVER (PARTITION BY p.contract_address ORDER BY call_block_time DESC), 3) AS price_today
      FROM 
        yearn_v2."yVault_call_pricePerShare" p
        INNER JOIN yearn."yearn_all_vaults" y ON y.contract_address = p.contract_address
      WHERE call_success = TRUE
      UNION
      SELECT DISTINCT
        p.contract_address,
        ROUND(FIRST_VALUE(p.output_0 / 10 ^ (y.decimals)) OVER (PARTITION BY p.contract_address ORDER BY call_block_time DESC), 3) AS price_today
      FROM 
        yearn."yVault_call_getPricePerFullShare" p
        INNER JOIN yearn."yearn_all_vaults" y ON y.contract_address = p.contract_address
      WHERE call_success = TRUE
      UNION
      SELECT DISTINCT
        p.contract_address,
        ROUND(FIRST_VALUE(p.output_0 / 10 ^ (y.decimals)) OVER (PARTITION BY p.contract_address ORDER BY call_block_time DESC), 3) AS price_today
      FROM 
        iearn_v1."yToken_call_getPricePerFullShare" p
        INNER JOIN yearn."yearn_all_vaults" y ON y.contract_address = p.contract_address
      WHERE call_success = TRUE
      UNION
      SELECT DISTINCT
        p.contract_address,
        ROUND(FIRST_VALUE(p.output_0 / 10 ^ (y.decimals)) OVER (PARTITION BY p.contract_address ORDER BY call_block_time DESC), 3) AS price_today
      FROM 
        iearn_v2."yToken_call_getPricePerFullShare" p
        INNER JOIN yearn."yearn_all_vaults" y ON y.contract_address = p.contract_address
      WHERE call_success = TRUE
    ) v
    WHERE price_today != 0 AND price_today < 10
  ),
  
  -- Get vault metadata and calculate days since launch
  days AS (
    SELECT 
      * 
    FROM (
      SELECT
        y.contract_address,
        CONCAT(y.ytoken, ' ', y.tag) AS vault,
        MIN(evt_block_time) AS start_date, 
        MAX(evt_block_time) AS last_active_date,
        EXTRACT(DAY FROM MAX(evt_block_time) - MIN(evt_block_time)) AS days_since_launch
      FROM 
        erc20."ERC20_evt_Transfer" t
        INNER JOIN yearn."yearn_all_vaults" y ON y.contract_address = t.contract_address
      GROUP BY 1, 2
    ) p
    WHERE days_since_launch != 0
  )

SELECT 
  d.vault,
  p.price_today,
  -- p.price_launch,
  d.start_date,
  d.last_active_date,
  d.days_since_launch, 
  ((p.price_today - 1) * (365 / d.days_since_launch)) AS yearly_ROI
FROM 
  vault_price_per_share p
  INNER JOIN days d ON p.contract_address = d.contract_address
ORDER BY 5 ASC;