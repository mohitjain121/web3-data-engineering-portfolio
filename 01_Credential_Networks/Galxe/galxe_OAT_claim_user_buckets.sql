/* 
Description: Calculates the distribution of claim counts per user into predefined buckets.
*/
WITH
oat_claim_user AS (
    SELECT
        account AS "OAT User",
        COUNT(DISTINCT cid) AS "Number of Claims"
    FROM
        project_galaxy."GalaxyOAT_call_mint"
    WHERE
        call_success = TRUE
    GROUP BY
        1
)
SELECT
    COUNT("OAT User") AS "Bucket",
    SUM(CASE WHEN "Number of Claims" < 10 THEN 1 ELSE 0 END) AS "0-10",
    SUM(CASE
            WHEN "Number of Claims" >= 10
            AND "Number of Claims" < 25 THEN 1
            ELSE 0
        END) AS "10 - 25",
    SUM(CASE
            WHEN "Number of Claims" >= 25
            AND "Number of Claims" < 50 THEN 1
            ELSE 0
        END) AS "25 - 50",
    SUM(CASE
            WHEN "Number of Claims" >= 50
            AND "Number of Claims" < 100 THEN 1
            ELSE 0
        END) AS "50 - 100",
    SUM(CASE
            WHEN "Number of Claims" >= 100
            AND "Number of Claims" < 200 THEN 1
            ELSE 0
        END) AS "100 - 200",
    SUM(CASE
            WHEN "Number of Claims" >= 200 THEN 1
            ELSE 0
        END) AS ">200"
FROM
    oat_claim_user