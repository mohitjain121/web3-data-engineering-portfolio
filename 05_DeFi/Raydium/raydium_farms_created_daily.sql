/* Description: Extract farm launch dates and cumulative farm counts. */
SELECT 
    launch_date,
    count_farms,
    COUNT(count_farms) OVER (ORDER BY launch_date) AS cumulative_farms
FROM 
(
    SELECT 
        launch_date,
        COUNT(pool) AS count_farms
    FROM 
    (
        SELECT 
            CASE 
                WHEN array_contains(account_keys, 'SQ916wkRcZKWB9tA5pnCPq4ETLryy4Ti6RJv1YuDwyZ') THEN 'WEYU-USDC'
                WHEN array_contains(account_keys, 'EGSLct8CuJ7XG8MWAXyQGcJRUx9Zp1VjJZ6BrohU3Pnh') THEN '$GARY-SOL'
                WHEN array_contains(account_keys, '5EGnYoXC3edoxE83XcYocXK6zumzqLePz2NAWyr1sGSw') THEN 'ARB-USDC'
                WHEN array_contains(account_keys, 'HBeYLGqpsigjivaxRH8ar6o9CW2ZYjocm8bgHQcRGc49') THEN 'XTR-USDC'
                WHEN array_contains(account_keys, '2goPFTR7vEZikmi38aQxvBrEdWHp2y2XPNzHFzgjv6Ek') THEN 'GXE-USDC'
                WHEN array_contains(account_keys, 'CkDZLC7CTtdqxi2L2saf8vCaDySUTRG38VD6f9imQsKC') THEN 'NARK-USDC'
                WHEN array_contains(account_keys, '3evGyKgnhLxtYd78nG72Lvo9LmBRrQcnN27nsztsLPNm') THEN 'LRA-USDC'
                WHEN array_contains(account_keys, '25PfejzbsWBs3uCHDVDjSiQ9rWBq7FfjgKed4hQFT5Mx') THEN 'MINECRAFT-USDC'
                WHEN array_contains(account_keys, '5PqxUnh7PciEUA6EMvhFnt5jtUHkJdJ6j1TbRrLNAGjE') THEN 'USDT-USDC'
            END AS pool,
            MIN(block_date) AS launch_date
        FROM solana.transactions
        WHERE 
            array_contains(account_keys, 'FarmqiPv5eAj3j1GMdMCMUGXqPUvmquZtMy86QH6rzhG')
            AND success = true
            AND block_time >= '2022-07-01'
        GROUP BY 1
    ) x
    GROUP BY 1
)
ORDER BY launch_date DESC