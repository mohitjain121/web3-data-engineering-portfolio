/* Description: Count distinct transactions and users for specific addresses */
SELECT
    COUNT(DISTINCT hash) AS txns,
    COUNT(DISTINCT "from") AS users
FROM
    polygon.transactions
WHERE
    "to" IN (
        '\x35AF667AfD82DE3c224Fcfca9a66D32B586F6D60',
        '\x59e0aD27d0F58A15128051cAA1D2917aA71AB864',
        '\x3fc376530Ac35d37Dd1Fa794F922e0f30CbB2c46',
        '\xd71b0366CD2f2E90dd1F80A1F0EA540F73Ac0EF6')