/* Description: Calculate bet sizes for transactions involving a specific contract address. */

WITH
  price AS (
    SELECT
      hour:: DATE AS datex,
      decimals,
      contract_address,
      AVG(median_price) AS price
    FROM
      prices."prices_from_dex_data"
    WHERE 
      symbol = 'USDC'
    GROUP BY
      1,
      2,
      3
  )

SELECT
  DISTINCT date_trunc('DAY', block_time) AS datex,
  CONCAT(
    '<a href="https://etherscan.io/tx/0',
    SUBSTRING("hash":: text, 2),
    '" target="_blank" >',
    "hash",
    '</a>'
  ) AS tx_hash,
  t.value * p.price / 10 ^ p.decimals AS bet_size
FROM
  ethereum."transactions" x
  INNER JOIN erc20."ERC20_evt_Transfer" t ON t.evt_tx_hash = x.hash
  LEFT JOIN price p ON p.datex = x.block_time:: DATE
  AND p.contract_address = t.contract_address
WHERE
  x."to" = '\xc61d1dcCEeec03c94d729D8F8344ce3Be75d09fE'
  AND success = true
  AND SUBSTRING(x.data for 4) = '\xb9104f82'
ORDER BY 3 DESC;