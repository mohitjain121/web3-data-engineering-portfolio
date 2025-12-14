/* Description: Calculate user metrics from blockchain data */

WITH 
deposits AS
(SELECT
    t."from" AS user,
    SUM(value/1e6) AS deposits
FROM
    erc20."ERC20_evt_Transfer" t 
    INNER JOIN logium."LogiumCore_call_deposit" d ON t.evt_tx_hash = d.call_tx_hash
GROUP BY 1),

withdrawals AS 
(SELECT
    t."to" AS user,
    SUM(value/1e6) AS withdrawals
FROM
    erc20."ERC20_evt_Transfer" t 
    INNER JOIN logium."LogiumCore_call_withdraw" d ON t.evt_tx_hash = d.call_tx_hash
GROUP BY 1),

winners AS
(SELECT
    winner AS user,
    COUNT(amount) AS count_wins,
    SUM(amount) AS total_winnings,
    MAX(amount) AS biggest_win
FROM
(SELECT
    "to" AS winner,
    value/1e6 AS amount
FROM erc20."ERC20_evt_Transfer"
WHERE evt_tx_hash IN 
    (SELECT evt_tx_hash FROM erc20."ERC20_evt_Transfer" WHERE "to" = '\x1a95a459713e4934aa1453688d971ac7eb812c8e')
    AND "to" != '\x1a95a459713e4934aa1453688d971ac7eb812c8e') x
GROUP BY 1),

participant AS 
(SELECT
    participant AS user,
    SUM(COALESCE(entry,0)) AS total_entry,
    MAX(COALESCE(entry,0)) AS biggest_bet,
    COUNT(COALESCE(entry,0)) AS count_bets
FROM
(SELECT
    issuer AS participant,
    value AS entry
FROM
(SELECT
    evt_tx_hash,
    value/1e6 AS value
FROM
    erc20."ERC20_evt_Transfer"
WHERE "to" IN 
    (SELECT
    output_0 FROM logium."LogiumCore_call_takeTicket" WHERE call_success = true)
    AND evt_block_time >= '2022-06-12') x INNER JOIN 
(SELECT
    issuer,
    trader,
    evt_tx_hash
FROM
    logium."LogiumCore_evt_BetEmitted") y ON x.evt_tx_hash = y.evt_tx_hash
UNION
SELECT
    trader AS participant,
    value AS entry
FROM
(SELECT
    evt_tx_hash,
    value/1e6 AS value
FROM
    erc20."ERC20_evt_Transfer"
WHERE "to" IN 
    (SELECT
    output_0 FROM logium."LogiumCore_call_takeTicket" WHERE call_success = true)
    AND evt_block_time >= '2022-06-12') x INNER JOIN 
(SELECT
    issuer,
    trader,
    evt_tx_hash
FROM
    logium."LogiumCore_evt_BetEmitted") y ON x.evt_tx_hash = y.evt_tx_hash) x
GROUP BY 1
    ),


metrics AS 
(
SELECT
    wallet_address,
    COALESCE(deposits, 0) AS deposits,
    COALESCE(withdrawals, 0) AS withdrawals,
    count_wins AS count_wins,
    count_bets AS count_bets,
    -- count_losses,
    total_winnings AS total_winnings,
    total_entry AS total_entry,
    -- total_losses,
    biggest_win AS biggest_win,
    biggest_bet AS biggest_bet
FROM
(SELECT
    COALESCE(d.user, w.user, i.user, l.user) AS wallet_address,
    deposits,
    withdrawals,
    count_bets,
    count_wins,
    count_bets - count_wins AS count_losses,
    total_entry,
    total_winnings,
    CASE 
        WHEN total_winnings - total_entry > 0 THEN NULL
        WHEN total_winnings - total_entry < 0 THEN total_winnings - total_entry END AS total_losses,
    biggest_bet,
    biggest_win
FROM
    deposits d
    FULL JOIN withdrawals w ON d.user = w.user
    FULL JOIN winners i ON d.user = i.user
    FULL JOIN participant l ON d.user = l.user ) x

)
SELECT
    *
FROM metrics
WHERE wallet_address = CONCAT('\x', substring('{{Wallet Address}}' from 3))::BYTEA;