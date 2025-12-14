/*
Description: Calculate APY for each pool based on last week's stake and current rewards.
*/

WITH 
  last_week_stake AS (
    SELECT 
      pool_id,
      lw_own_stake,
      lw_del_stake,
      lw_own_stake + lw_del_stake AS lw_total_stake
    FROM (
      SELECT 
        pool_id,
        MAX(CASE WHEN stake_type = 2 THEN total_allocated ELSE 0 END) AS lw_own_stake,
        MAX(CASE WHEN stake_type = 3 THEN total_allocated ELSE 0 END) AS lw_del_stake
      FROM (
        SELECT 
          pool_id,
          stake_type,
          SUM(total_allocated) AS total_allocated
        FROM (
          SELECT DISTINCT 
            subject AS pool_id,
            subjectType AS stake_type,
            FIRST_VALUE(totalAllocated) OVER (PARTITION BY subject, subjectType ORDER BY evt_block_time DESC, evt_index DESC) / 1e18 AS total_allocated
          FROM forta_network_polygon.StakeAllocator_evt_AllocatedStake
          WHERE evt_block_time < date_trunc('week', current_date) - interval '7' day
        ) x 
        GROUP BY 
          1, 2
      ) y
      GROUP BY 
        1
    ) AS y
  ), 

  current_stake AS (
    SELECT 
      pool_id,
      c_own_stake,
      c_del_stake,
      c_own_stake + c_del_stake AS c_total_stake
    FROM (
      SELECT 
        pool_id,
        MAX(CASE WHEN stake_type = 2 THEN total_allocated ELSE 0 END) AS c_own_stake,
        MAX(CASE WHEN stake_type = 3 THEN total_allocated ELSE 0 END) AS c_del_stake
      FROM (
        SELECT 
          pool_id,
          stake_type,
          SUM(total_allocated) AS total_allocated
        FROM (
          SELECT DISTINCT 
            subject AS pool_id,
            subjectType AS stake_type,
            FIRST_VALUE(totalAllocated) OVER (PARTITION BY subject, subjectType ORDER BY evt_block_time DESC, evt_index DESC) / 1e18 AS total_allocated
          FROM forta_network_polygon.StakeAllocator_evt_AllocatedStake
        ) x 
        GROUP BY 
          1, 2
      ) y
      GROUP BY 
        1
    ) AS y
  ), 

  reward AS (
    SELECT 
      COALESCE(a.pool_id, b.pool_id) AS pool_id,
      commission,
      own_reward,
      del_reward
    FROM (
      SELECT 
        pool_id,
        MAX(CASE WHEN stake_type = 2 THEN amt_rewarded ELSE 0 END) AS own_reward,
        MAX(CASE WHEN stake_type = 3 THEN amt_rewarded ELSE 0 END) AS del_reward
      FROM (
        SELECT 
          subject AS pool_id, 
          subjectType AS stake_type,
          FIRST_VALUE(amount) OVER (PARTITION BY subject, subjectType ORDER BY evt_block_time DESC) / 1e18 AS amt_rewarded
        FROM 
          forta_polygon.RewardsDistributor_evt_Rewarded
        WHERE 
          epochNumber IN (SELECT max(epochNumber) FROM forta_polygon.RewardsDistributor_evt_Rewarded)
      ) x
      GROUP BY 
        1
    ) AS a
    FULL JOIN (
      SELECT DISTINCT 
        subject AS pool_id,
        CAST(FIRST_VALUE(feeBps / 100) OVER (PARTITION BY subject ORDER BY evt_block_time DESC) AS DOUBLE) AS commission
      FROM forta_polygon.RewardsDistributor_evt_SetDelegationFee
      WHERE evt_block_time < date_trunc('week', current_date) - interval '7' day
    ) AS b
      ON a.pool_id = b.pool_id
  )

SELECT 
  COALESCE(a.pool_id, b.pool_id) AS pool_id,
  commission,
  ROUND(c_own_stake, 1) AS own_stake,
  ROUND(COALESCE(own_reward, 0), 1) AS own_reward,
  ROUND(c_del_stake, 1) AS del_stake,
  ROUND(COALESCE(del_reward, 0), 1) AS del_reward,
  ROUND(c_total_stake, 1) AS total_stake,
  CASE 
    WHEN (del_reward = 0 OR lw_del_stake = 0)
    THEN POWER(1 + (1 - commission * 0.01) * (own_reward / lw_total_stake), 52) - 1
    ELSE POWER(1 + del_reward / lw_del_stake, 52) - 1
  END AS apy
FROM 
  last_week_stake AS a
  FULL JOIN reward AS b ON a.pool_id = b.pool_id
  FULL JOIN current_stake AS c ON a.pool_id = c.pool_id
WHERE 
  lw_total_stake != 0
ORDER BY 
  apy DESC