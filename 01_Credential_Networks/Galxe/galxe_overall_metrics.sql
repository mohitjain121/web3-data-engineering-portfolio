/* 
Description: Calculates total claimed NFTs, campaigns, and unique users, and derives the average NFTs claimed per campaign.
*/
WITH nft_claimed AS
(
    SELECT
        COUNT(DISTINCT "_nftID") AS "NFTs Claimed"
    FROM
        (
        SELECT DISTINCT
            "_nftID"
        FROM
            project_galaxy."SpaceStation_evt_EventClaim"
        UNION
        SELECT DISTINCT
            "_nftID"
        FROM
            project_galaxy."SpaceStation_evt_EventForge"
        UNION
        SELECT DISTINCT
            unnest("_nftIDArr") AS "_nftID"
            -- UNNEST handles array expansion for batch claims
        FROM
            project_galaxy."SpaceStation_evt_EventClaimBatch"
        ) x
),

no_camp AS
(
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
        ) x
),

no_sender AS
(
    SELECT
        COUNT(DISTINCT _sender) AS "Number of Users"
    FROM
        (
        SELECT DISTINCT
            _sender
        FROM
            project_galaxy."SpaceStation_evt_EventClaimBatch"
        UNION
        SELECT DISTINCT
            _sender
        FROM
            project_galaxy."SpaceStation_evt_EventClaim"
        UNION
        SELECT DISTINCT
            _sender
        FROM
            project_galaxy."SpaceStation_evt_EventForge"
        ) x
)

SELECT
    "NFTs Claimed",
    "Number of Campaigns",
    "Number of Users",
    CAST("NFTs Claimed" AS FLOAT) / CAST("Number of Campaigns" AS FLOAT) AS "AVG NFT Per Campaign"
FROM
    nft_claimed,
    no_camp,
    no_sender