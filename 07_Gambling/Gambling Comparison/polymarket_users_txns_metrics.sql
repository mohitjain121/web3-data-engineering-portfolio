/* Description: Count unique users and transactions by specified addresses and date range */
SELECT
    COUNT(DISTINCT "to") AS users,
    COUNT(hash) AS txns
FROM
    polygon."transactions"
WHERE 
    "from" IN (
        '\x3a9a17241db35c6722b63db2e66186cfe2d3ca65', 
        '\x7eb2cdeab410245f1cd16055b1cc6bc9ade6976a',
        '\xec6082b67fc820073f427690df1a6b7b234bd1b6'
    )
    AND block_time >= '2021-01-01'