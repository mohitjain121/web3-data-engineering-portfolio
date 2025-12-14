/* Description: Calculate cumulative wallets by date. */

SELECT
    datex,
    wallets,
    SUM(wallets) OVER (ORDER BY datex ASC) AS cumulative_wallets
FROM
(
    SELECT
        datex,
        COUNT(DISTINCT wallet) AS wallets
    FROM
    (
        SELECT
            "sender" AS wallet,
            date_trunc('DAY', MIN(evt_block_time)) AS datex
        FROM
            wombat."DynamicPool_evt_Deposit"
        WHERE
            "token" = '\x1bdd3Cf7F79cfB8EdbB955f20ad99211551BA275' -- BNBx token
        GROUP BY
            1
    ) x
    GROUP BY
        1
) x
ORDER BY
    1 DESC