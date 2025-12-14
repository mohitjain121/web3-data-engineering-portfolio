/* Description: Calculate the total value and number of users for a specific contract */
SELECT
    SUM(value)/1e18 AS total_value,
    COUNT(DISTINCT "to") AS users
FROM
    polygon."transactions"
WHERE
    "from" = '\x58F2F45a98bC827A141BEe028b7500218272A2e7' -- withdrawal contract