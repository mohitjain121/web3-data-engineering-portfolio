/*
Description: Calculates the average number of NFTs claimed per campaign across various claim methods.
*/
WITH nft_claims AS (
    SELECT
        SUM("Number of Claims") AS "NFTs Claimed"
    FROM
        (
            SELECT
                "Campaign ID",
                "Number of Claims",
                "Unique Campaign Participants"
            FROM
                (
                    -- Aggregation for standard claims
                    SELECT
                        _cid AS "Campaign ID",
                        COUNT(_sender) AS "Number of Claims",
                        COUNT(DISTINCT _sender) AS "Unique Campaign Participants"
                    FROM
                        project_galaxy."SpaceStation_evt_EventClaim"
                    GROUP BY
                        1

                    UNION

                    -- Aggregation for forge claims
                    SELECT
                        _cid AS "Campaign ID",
                        COUNT(_sender) AS "Number of Claims",
                        COUNT(DISTINCT _sender) AS "Unique Campaign Participants"
                    FROM
                        project_galaxy."SpaceStation_evt_EventForge"
                    GROUP BY
                        1

                    UNION

                    -- Aggregation for batch claims (array_length determines claim count)
                    SELECT
                        _cid AS "Campaign ID",
                        SUM(array_length("_nftIDArr", 1)) AS "Number of Claims",
                        COUNT(DISTINCT _sender) AS "Unique Campaign Participants"
                    FROM
                        project_galaxy."SpaceStation_evt_EventClaimBatch"
                    GROUP BY
                        1
                ) AS x
            GROUP BY
                1, 2, 3
            ORDER BY
                2 DESC
        ) AS y
),

no_camp AS (
    SELECT
        COUNT(DISTINCT _cid) AS "Number of Campaigns"
    FROM
        (
            SELECT DISTINCT
                _cid
            FROM
                project_galaxy."SpaceStation_evt_EventClaimBatch"

            UNION

            SELECT DISTINCT
                _cid
            FROM
                project_galaxy."SpaceStation_evt_EventClaim"

            UNION

            SELECT DISTINCT
                _cid
            FROM
                project_galaxy."SpaceStation_evt_EventForge"
        ) AS x
)

SELECT
    CAST(nft_claims."NFTs Claimed" AS FLOAT) / CAST(no_camp."Number of Campaigns" AS FLOAT) AS "AVG NFT Per Campaign"
FROM
    nft_claims,
    no_camp