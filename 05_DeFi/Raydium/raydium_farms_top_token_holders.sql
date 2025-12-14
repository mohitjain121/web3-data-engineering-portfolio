/* Description: Calculate token holdings and percentages for top holders. */

WITH
  holder_final_transaction AS (
    SELECT
      post_token_balance.account AS holder_address,
      MAX(block_slot) AS last_block_slot
    FROM
      solana.transactions
      LATERAL VIEW EXPLODE(post_token_balances) balances AS post_token_balance
    WHERE
      block_time >= '2022-07-01'
      AND success = TRUE
      AND post_token_balance.mint = '5mB7vE4LsYjVBroxgPQKC5GRNK5X2fJtNBzF77qPSPwS'
    GROUP BY
      post_token_balance.account
  )
SELECT
  holder_address,
  ROUND(post_token_balance.amount) AS token_amount,
  (post_token_balance.amount / SUM(post_token_balance.amount) OVER ()) AS percent_holding
FROM
  solana.transactions a
  INNER JOIN holder_final_transaction b ON a.block_slot = b.last_block_slot
  LATERAL VIEW EXPLODE(post_token_balances) balances AS post_token_balance
WHERE
  block_time >= '2022-07-01'
  AND success = TRUE
  AND block_slot IN (
    SELECT
      last_block_slot
    FROM
      holder_final_transaction
  )
  AND post_token_balance.mint = '5mB7vE4LsYjVBroxgPQKC5GRNK5X2fJtNBzF77qPSPwS'
  AND post_token_balance.account = b.holder_address
  AND ROUND(post_token_balance.amount) > 0
ORDER BY
  2 DESC
LIMIT
  20;