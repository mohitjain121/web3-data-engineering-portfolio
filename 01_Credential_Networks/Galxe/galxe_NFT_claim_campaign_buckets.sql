/* 
Description: Calculates claim volume distribution across campaign claim counts using specific event logs.
*/
WITH
claim_camp AS (
    SELECT
        _cid AS "Campaign ID",
        COUNT("NFT") AS "Number of Claims"
    FROM
        (
            -- Aggregating claims from standard event log
            SELECT
                _cid,
                "_nftID" AS "NFT"
            FROM
                project_galaxy."SpaceStation_evt_EventClaim"

            UNION

            -- Expanding batched claims using UNNEST for array processing
            SELECT
                _cid,
                UNNEST("_nftIDArr") AS "NFT"
            FROM
                project_galaxy."SpaceStation_evt_EventClaimBatch"

            UNION

            -- Aggregating claims from forge events
            SELECT
                _cid,
                "_nftID" AS "NFT"
            FROM
                project_galaxy."SpaceStation_evt_EventForge"
        ) AS x
    GROUP BY
        1
)
SELECT
    COUNT("Campaign ID") AS "Bucket",
    SUM(
        CASE
            WHEN "Number of Claims" < 100 THEN 1
            ELSE 0
        END
    ) AS "0-100",
    SUM(
        CASE
            WHEN "Number of Claims" >= 100
            AND "Number of Claims" < 250 THEN 1
            ELSE 0
        END
    ) AS "100 - 250",
    SUM(
        CASE
            WHEN "Number of Claims" >= 250
            AND "Number of Claims" < 500 THEN 1
            ELSE 0
        END
    ) AS "250 - 500",
    SUM(
        CASE
            WHEN "Number of Claims" >= 500
            AND "Number of Claims" < 1000 THEN 1
            ELSE 0
        END
    ) AS "500 - 1000",
    SUM(
        CASE
            WHEN "Number of Claims" >= 1000
            AND "Number of Claims" < 5000 THEN 1
            ELSE 0
        END
    ) AS "1000 - 5000",
    SUM(
        CASE
            WHEN "Number of Claims" >= 5000
            AND "Number of Claims" < 10000 THEN 1
            ELSE 0
        END
    ) AS "5000 - 10000",
    SUM(
        CASE
            WHEN "Number of Claims" >= 10000 THEN 1
            ELSE 0
        END
    ) AS ">10000"
FROM
    claim_camp