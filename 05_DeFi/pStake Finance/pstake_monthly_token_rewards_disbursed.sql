/* Description: Calculate rewards and prices for Atom and XPRT tokens. */

WITH 
  -- Calculate monthly average price for Atom
  price1 AS (
    SELECT 
      date_trunc('MONTH', minute) AS datex,
      AVG(price) AS price
    FROM 
      prices."layer1_usd"
    WHERE 
      symbol = 'ATOM'
    GROUP BY 1
  ), 

  -- Calculate monthly average price for XPRT
  price2 AS (
    SELECT 
      date_trunc('MONTH', hour) AS datex,
      AVG(median_price) AS price
    FROM 
      dex."view_token_prices"
    WHERE 
      contract_address = '\x45e007750Cc74B1D2b4DD7072230278d9602C499'
    GROUP BY 1
  ), 

  -- Calculate monthly rewards for Atom
  reward1 AS (
    SELECT 
      date_trunc('MONTH', t.evt_block_time) AS datex, 
      SUM(value)/10^6 AS reward_atom
    FROM 
      pstake."StakeLP_evt_TriggeredCalculateSyncedRewards" r 
      INNER JOIN erc20."ERC20_evt_Transfer" t 
      ON t.evt_tx_hash = r.evt_tx_hash 
      AND t."from" = r."holderAddress"
      AND t."to" = r."accountAddress"
    WHERE 
      t.contract_address = '\x446e028f972306b5a2c36e81d3d088af260132b3' --pAtom
    GROUP BY 1
  ), 

  -- Calculate monthly rewards for XPRT
  reward2 AS (
    SELECT 
      date_trunc('MONTH', t.evt_block_time) AS datex, 
      SUM(value)/10^6 AS reward_xprt
    FROM 
      pstake."StakeLP_evt_TriggeredCalculateSyncedRewards" r 
      INNER JOIN erc20."ERC20_evt_Transfer" t 
      ON t.evt_tx_hash = r.evt_tx_hash 
      AND t."from" = r."holderAddress"
      AND t."to" = r."accountAddress"
    WHERE 
      t.contract_address = '\x8793cd84c22b94b1fdd3800f02c4b1dcca40d50b' --pXPRT
    GROUP BY 1
  )

SELECT 
  r1.datex,
  p1.price AS "atom_price",
  COALESCE(reward_atom, 0) AS reward_atom,
  COALESCE(reward_atom * p1.price, 0) AS "$rewards_patom",
  p2.price AS "xprt_price",
  COALESCE(reward_xprt, 0) AS reward_xprt,
  COALESCE(reward_xprt * p2.price, 0) AS "$rewards_pxprt",
  COALESCE(reward_atom * p1.price, 0) + COALESCE(reward_xprt * p2.price, 0) AS "total_$rewards"
FROM 
  reward1 r1
  FULL JOIN reward2 r2 ON r1.datex = r2.datex
  LEFT JOIN price1 p1 ON p1.datex = r1.datex
  LEFT JOIN price2 p2 ON p2.datex = r2.datex
ORDER BY 
  1 DESC;