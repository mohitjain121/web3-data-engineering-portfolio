/* Description: Count distinct transactions and users for specified recipients */
SELECT
    COUNT(DISTINCT hash) AS txns,
    COUNT(DISTINCT "from") AS users
FROM
    bsc.transactions
WHERE
    "to" IN (
        '\xBE6CB6EaDf1bF80A991EB6F6fbf865eF6bA26E3B',
        '\x31b8a8ee92961524fd7839dc438fd631d34b49c6',
        '\xe39a6a119e154252214b369283298cdf5396026b',
        '\x3Df33217F0f82c99fF3ff448512F22cEf39CC208')