/*
Description: Counts the number of unique user addresses interacting with specific Galaxy/NFT related smart contracts on the Polygon network.
*/
SELECT
    COUNT(DISTINCT "from") AS "total galaxy users"
FROM
    polygon.transactions
WHERE
    "to" IN (
        '\x6cad6e1abc83068ea98924aef37e996ed02abf1c', -- Spacestation
        '\xdeb1f826c512eee2fa9398225a3401a0dd5311e2', -- Spacestation
        '\x44d2a93948b70dc0568020aad2efc6fe7d146404', -- Spacestation
        '\x6e7801d5b07da1a82f6d1930685731a50645b182', -- Spacestation
        '\x1871464F087dB27823Cff66Aa88599AA4815aE95', -- Galaxy OAT
        '\xBf232A580C3306F7A7cA90D09ec241F6818D06FA', -- StarNFT721
        '\x73bc0ba23ca13cb9a7fbeda5f661562ef985155e'  -- StarNFT721
    )
AND
    success = TRUE