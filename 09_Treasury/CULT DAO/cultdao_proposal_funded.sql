/* Description: Calculate Cult DAO proposal metrics */
WITH 
  -- Get the first transfer for each transaction
  table0 AS (
    SELECT 
      contract_address,
      evt_tx_hash,
      evt_index,
      evt_block_time,
      evt_block_number,
      "from",
      to,
      cult_amount,
      dead,
      ROW_NUMBER() OVER ( PARTITION BY evt_tx_hash ORDER BY evt_block_time, cult_amount DESC) AS row_num 
    FROM (
      SELECT 
        contract_address,
        evt_tx_hash,
        evt_index,
        evt_block_time,
        evt_block_number,
        "from",
        to,
        (cast(value AS DECIMAL)/1e18) AS cult_amount,
        CASE 
          WHEN cast(to AS varchar) = cast(0x000000000000000000000000000000000000dead AS VARCHAR) THEN 1 
          ELSE 0 
        END AS dead
      FROM  cult_dao_ethereum.Cult_evt_Transfer AS culttransfer
      WHERE cast(contract_address AS varchar) = cast(0xf0f9D895aCa5c8678f706FB8216fa22957685A13 AS varchar)
      AND cast("from" AS varchar) = cast(0x55AC81186E1A8454c79aD78C615c43f54F87403B AS varchar)
      ORDER BY evt_block_time DESC
    )
  ),
  
  -- Get the first transfer for each transaction
  table1 AS (
    SELECT 
      contract_address,
      evt_tx_hash,
      evt_index,
      evt_block_time,
      evt_block_number,
      "from",
      to,
      cult_amount,
      dead,
      row_num
    FROM table0
    WHERE row_num = 1
  ),
  
  -- Get the first transfer for each transaction
  cult_sent_from_treasury AS (
    SELECT 
      ROW_NUMBER() OVER ( ORDER BY evt_block_time, evt_block_number DESC) AS cult_sent_from_treasury_id,
      contract_address,
      evt_tx_hash,
      evt_index,
      evt_block_time,
      evt_block_number,
      "from",
      to,
      cult_amount,
      dead,
      row_num 
    FROM table1
    ORDER BY evt_block_time DESC
  ),
  
  -- Get proposal details
  proposal_passed AS (
    WITH 
      -- Get vote details
      votes AS (
        SELECT  
          voter,
          CASE WHEN cast(support as integer) = 1 THEN votes/(cast(power(10,18) as uint256)) END AS votes_for,
          CASE WHEN cast(support as integer) = 0 THEN votes/(cast(power(10,18) as uint256)) END AS votes_against,
          CASE WHEN support = 1 THEN 1 END AS voter_for,
          CASE WHEN support = 0 THEN 1 END AS voter_against,
          proposalId,
          contract_address
        FROM cult_dao_ethereum.GovernorBravoDelegate_evt_VoteCast
      ),
      
      -- Get proposal details
      proposals AS (
        SELECT 
          id,
          contract_address,
          proposer,
          evt_block_time,
          description
        FROM cult_dao_ethereum.GovernorBravoDelegate_evt_ProposalCreated
      ),
      
      -- Get proposal details
      proposal_description AS (
        SELECT 
          p.id AS proposal_id,
          CASE WHEN exec.id IS NOT NULL THEN 'FUNDED' ELSE 'NONFUNDED' END AS proposal_decision,
          p.evt_block_time AS created_date,
          --COALESCE(1, proposer) AS "Proposer",
          Proposer,
          CASE 
            WHEN (SUM(votes_for)) IS NULL AND (SUM(votes_against)) IS NOT NULL THEN  (SUM(votes_against)) 
            WHEN (SUM(votes_against)) IS NULL AND (SUM(votes_for)) IS NOT NULL THEN  (SUM(votes_for))
            WHEN ((SUM(votes_for)) + (SUM(votes_against))) IS NOT NULL THEN ((SUM(votes_for)) + (SUM(votes_against))) 
            ELSE (cast(0 AS uint256))
          END AS total_votes,
  
          CASE WHEN (SUM(votes_for)) IS NULL THEN (cast(0 AS uint256)) ELSE (SUM(votes_for)) END AS votesfor,
          CASE WHEN (SUM(votes_against)) IS NULL THEN (cast(0 AS uint256)) ELSE (SUM(votes_against)) END AS votesagainst ,
    
          CASE 
            WHEN (SUM(voter_for)) IS NULL AND (SUM(voter_against)) IS NOT NULL THEN  (SUM(voter_against)) 
            WHEN (SUM(voter_against)) IS NULL AND (SUM(voter_for)) IS NOT NULL THEN  (SUM(voter_for))
            WHEN ((SUM(voter_for)) + (SUM(voter_against))) IS NOT NULL THEN ((SUM(voter_for)) + (SUM(voter_against))) 
            ELSE 0
          END AS total_voters,
         
          CASE WHEN (SUM(voter_for)) IS NULL THEN 0 ELSE (SUM(voter_for)) END AS votersfor,
          CASE WHEN (SUM(voter_against)) IS NULL THEN 0 ELSE (SUM(voter_against)) END AS voters_against,   
          json_query(description,'strict $.projectName' OMIT QUOTES) AS proposal_name,
          json_query(description,'strict $.shortDescription' OMIT QUOTES) AS short_description,
          json_query(description,'strict $.file' OMIT QUOTES) AS file,
          json_query(description,'strict $.socialChannel' OMIT QUOTES) AS social_channel,
          json_query(description,'strict $.links' OMIT QUOTES) AS links,
          json_query(description,'strict $.range' OMIT QUOTES) AS range,
          json_query(description,'strict $.rate' OMIT QUOTES) AS rate,
          json_query(description,'strict $.time' OMIT QUOTES) AS time,
          json_query(description,'strict $.checkbox1' OMIT QUOTES) AS checkbox1,
          json_query(description,'strict $.checkbox2' OMIT QUOTES) AS checkbox2,
          cast(json_query(description,'strict $.wallet' OMIT QUOTES) AS VARCHAR) AS wallet,
          cast(json_query(description,'strict $.guardianProposal' OMIT QUOTES) AS VARCHAR) AS guardian_proposal,
          json_query(description,'strict $.guardianDiscord' OMIT QUOTES) AS guardian_discord,
          json_query(description,'strict $.guardianAddress' OMIT QUOTES) AS guardian_address,
          exec.evt_block_time AS proposal_funded
    
        FROM proposals AS p
        LEFT JOIN votes AS v
          ON p.id = v.proposalId AND p.contract_address = v.contract_address
        LEFT JOIN cult_dao_ethereum.GovernorBravoDelegate_evt_ProposalExecuted AS exec
          ON p.id = exec.id
        GROUP BY p.id, description, proposer, p.evt_block_time, exec.id , exec.evt_block_time
        ORDER BY p.id ASC 
      ),
      
      -- Get proposal details
      proposal_description_final AS (
        SELECT 
          proposal_id,
          proposal_decision,
          created_date,
          proposal_funded,
          /*
          Here later add a formula to calculate the time between created and executed
          this would aslo be the time that the proposal was on time that votes where available 
          only if founded 
          */
          Proposer,
          total_votes,
          votesfor,
          votesagainst,
          total_voters,
          votersfor,
          voters_against,
          proposal_name,
          short_description,
          file,
          social_channel,
          links,
          range,
          rate,
          time,
          checkbox1,
          checkbox2,
          wallet,
          CASE 
            WHEN guardian_proposal IS NULL THEN 'unknown'
            WHEN guardian_proposal IS NOT NULL THEN guardian_proposal 
          END AS guardian_proposal,
          guardian_discord,
          guardian_address
        FROM proposal_description
      ),
      
      -- Get proposal details
      final AS (
        SELECT 
          proposal_id,
          proposal_decision,
          created_date,
          proposal_funded,
          Proposer,
          total_votes,
          votesfor AS "Total $CULT Amount Used To Vote YES",
          CASE 
            WHEN cast(total_votes AS VARCHAR) <> '0' THEN ((votesfor*100)/total_votes) 
            WHEN cast(total_votes AS VARCHAR) = '0' THEN total_votes
          END AS "% of YES Vote",
          votesagainst AS "Total $CULT Amount Used To Vote NO",
          CASE 
            WHEN cast(total_votes AS VARCHAR) <> '0' THEN ((votesagainst*100)/total_votes) 
            WHEN cast(total_votes AS VARCHAR) = '0' THEN total_votes
          END AS "% of No Vote",
          total_voters,
          votersfor,
          CASE 
            WHEN cast(total_voters AS VARCHAR) <> '0' THEN ((votersfor*100)/total_voters) 
            WHEN cast(total_voters AS VARCHAR) = '0' THEN total_voters
          END AS "% of YES Voters",
          voters_against,
          CASE 
            WHEN cast(total_voters AS VARCHAR) <> '0' THEN ((voters_against*100)/total_voters) 
            WHEN cast(total_voters AS VARCHAR) = '0' THEN total_voters
          END AS "% of No Voters",
          proposal_name,
          short_description,
          file,
          social_channel,
          links,
          range,
          rate,
          time,
          checkbox1,
          checkbox2,
          wallet,
          guardian_proposal,
          guardian_discord,
          guardian_address
        FROM proposal_description_final
        WHERE proposal_decision = 'FUNDED'
        AND wallet IS NOT NULL 
        ORDER BY proposal_funded DESC
      )
    SELECT 
      ROW_NUMBER() OVER ( ORDER BY proposal_funded, proposal_id DESC) AS cult_proposal_id,
      proposal_id,
      proposal_decision,
      created_date,
      proposal_funded,
      Proposer,
      total_votes,
      "Total $CULT Amount Used To Vote YES",
      "% of YES Vote",
      "Total $CULT Amount Used To Vote NO",
      "% of No Vote",
      total_voters,
      votersfor,
      "% of YES Voters",
      voters_against,
      "% of No Voters",
      proposal_name,
      short_description,
      file,
      social_channel,
      links,
      range,
      rate,
      time,
      checkbox1,
      checkbox2,
      wallet,
      guardian_proposal,
      guardian_discord,
      guardian_address
    FROM final
    ORDER BY proposal_funded DESC
  ),
  
  -- Get average CULT price
  average_cult_price AS (
    SELECT 
      datex,
      contract_address,
      symbol,
      AVG(cult_price) AS cult_price 
    FROM (
      SELECT 
        block_date AS datex,
        cast('0xf0f9d895aca5c8678f706fb8216fa22957685a13' AS VARCHAR) AS contract_address,
        cast('CULT' AS VARCHAR) AS symbol,
        lastest_cult_price AS cult_price
      FROM (
        SELECT * FROM (
          SELECT
            block_date,
            block_time,
            token_pair,
            amount_usd/token_bought_amount  AS lastest_cult_price,
            amount_usd/token_sold_amount  AS lastest_eth_price,
            blockchain,
            project,
            version
          FROM uniswap_v2_ethereum.trades
          WHERE (cast(token_bought_address AS VARCHAR) = '0xf0f9d895aca5c8678f706fb8216fa22957685a13')
          AND (cast(token_sold_address AS VARCHAR) = '0xc02aaa39b223fe8d0a0e5c4f27ead9083c756cc2')
          AND (token_bought_symbol = 'CULT')
          AND (token_sold_symbol = 'WETH')
          AND (token_bought_amount > 10)
          ORDER BY block_time DESC
        ) AS CULTBOUGHT

        UNION 

        SELECT * FROM (
          SELECT 
            block_date,
            block_time,
            token_pair,
            amount_usd/token_sold_amount AS lastest_cult_price,
            amount_usd/token_bought_amount AS lastest_eth_price,
            blockchain,
            project,
            version
          FROM uniswap_v2_ethereum.trades
          WHERE (cast(token_sold_address AS VARCHAR) = '0xf0f9d895aca5c8678f706fb8216fa22957685a13')
          AND (cast(token_bought_address AS VARCHAR) = '0xc02aaa39b223fe8d0a0e5c4f27ead9083c756cc2')
          AND (token_sold_symbol = 'CULT')
          AND (token_bought_symbol = 'WETH')
          AND (token_sold_amount > 10)
          ORDER BY block_time DESC
        )
        ORDER BY block_time DESC
      ) AS CULTSOLD
      ORDER BY datex DESC
    )
    GROUP BY 1, 2, 3
    ORDER BY datex DESC
  ),
  
  -- Get average WETH price
  weth_average_price AS (
    SELECT 
      cast(hour AS DATE) AS datex,
      contract_address,
      cast('WETH' AS VARCHAR) AS symbol,
      AVG(median_price) AS eth_price 
    FROM dex.prices
    WHERE blockchain = 'ethereum'
    AND cast(contract_address AS VARCHAR) = '0xc02aaa39b223fe8d0a0e5c4f27ead9083c756cc2'
    GROUP BY 1, 2, 3
    ORDER BY cast(hour AS DATE) DESC
  ),
  
  -- Get CULT vs ETH price
  cult_vs_eth_price AS (
    SELECT 
      cp.datex,
      cp.contract_address,
      cp.symbol,
      cp.cult_price, 
      ep.eth_price 
    FROM average_cult_price cp
    LEFT JOIN weth_average_price ep ON (ep.datex = cp.datex)
  ),
  
  -- Get 1 ETH equal CULT
  one_eth_equal_cult AS (
    SELECT 
      datex AS date,
      cult_price,
      eth_price,
      (eth_price/cult_price) AS eth_to_cult
    FROM cult_vs_eth_price
    ORDER BY datex DESC
  ),
  
  -- Join proposal and CULT data
  f1 AS (
    SELECT 
      csft.cult_sent_from_treasury_id,
      csft.contract_address,
      csft.evt_tx_hash,
      csft.evt_index,
      csft.evt_block_time,
      csft.evt_block_number,
      csft."from",
      csft.to,
      csft.cult_amount,
      csft.dead,
      csft.row_num,
      
      pp.cult_proposal_id,
      pp.proposal_id,
      pp.proposal_decision,
      pp.created_date,
      pp.proposal_funded,
      cast(pp.proposal_funded AS DATE) AS datex,
      pp.Proposer,
      pp.total_votes,
      pp."Total $CULT Amount Used To Vote YES",
      pp."% of YES Vote",
      pp."Total $CULT Amount Used To Vote NO",
      pp."% of No Vote",
      pp.total_voters,
      pp.votersfor,
      pp."% of YES Voters",
      pp.voters_against,
      pp."% of No Voters",
      pp.proposal_name,
      pp.short_description,
      pp.file,
      pp.social_channel,
      pp.links,
      pp.range,
      pp.rate,
      pp.time,
      pp.checkbox1,
      pp.checkbox2,
      pp.wallet,
      pp.guardian_proposal,
      pp.guardian_discord,
      pp.guardian_address
    FROM cult_sent_from_treasury AS csft 
    LEFT JOIN proposal_passed AS pp ON ( pp.cult_proposal_id = csft.cult_sent_from_treasury_id)
  ),
  
  -- Calculate additional metrics
  f2 AS (
    SELECT
      cult_sent_from_treasury_id,
      contract_address,
      evt_tx_hash,
      evt_index,
      evt_block_time,
      evt_block_number,
      "from",
      to,
      cult_amount,
      cult_price,
      cult_amount*cult_price AS usd_cult_value,
      eth_price,
      13*eth_price AS eth_cult_value,
      eth_to_cult,
      13*eth_to_cult AS cult_amount2,
      dead,
      row_num,
      cult_proposal_id,
      proposal_id,
      proposal_decision,
      created_date,
      proposal_funded,
      datex,
      Proposer,
      total_votes,
      "Total $CULT Amount Used To Vote YES",
      "% of YES Vote",
      "Total $CULT Amount Used To Vote NO",
      "% of No Vote",
      total_voters,
      votersfor,
      "% of YES Voters",
      voters_against,
      "% of No Voters",
      proposal_name,
      short_description,
      file,
      social_channel,
      links,
      range,
      rate,
      time,
      checkbox1,
      checkbox2,
      wallet,
      guardian_proposal,
      guardian_discord,
      guardian_address,    
      
      -- Add proposer name
      guardian_wallet_name  AS proposer_name
    FROM f1
    LEFT JOIN one_eth_equal_cult e2c ON (e2c.date = f1.datex)
    LEFT JOIN dune.modulus.dataset_cult_guardians_wallet AS cgw ON (lower(cast(cgw.proposal_made_by AS VARCHAR)) = lower(cast(f1.Proposer AS VARCHAR) ) )
    ORDER BY evt_block_time DESC
  ),
  
  -- Count proposals
  proposal_count AS (
    SELECT
      SUM(usd_cult_value) AS total_usd_value_funded,
      SUM(cult_amount) AS total_cult_invested,
      COUNT(cult_sent_from_treasury_id) AS cultdao_proposal_funded
    FROM f2
  )
  
  -- Final query
  SELECT 
    cultdao_proposal_funded,
    total_usd_value_funded,
    total_cult_invested,
    (cultdao_proposal_funded*13) AS total_eth_value_funded,
    (cultdao_proposal_funded*2.5) AS total_eth_value_burned
  FROM proposal_count