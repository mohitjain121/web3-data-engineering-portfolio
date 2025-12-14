/*
Description: Calculate average and median USD holdings for a set of wallets.
*/

WITH 
  price AS (
    SELECT 
      contract_address,
      decimals,
      symbol,
      AVG(price) AS price
    FROM 
      (
        SELECT 
          contract_address,
          decimals,
          symbol,
          AVG(price) AS price
        FROM 
          prices."usd"
        WHERE 
          minute > NOW() - '1 DAYS':: INTERVAL
        GROUP BY 
          1,
          2,
          3
        UNION
        SELECT 
          contract_address,
          decimals,
          p.symbol,
          AVG(price) AS price
        FROM 
          prices."layer1_usd" p
          LEFT JOIN erc20."tokens" t ON t.symbol = p.symbol
        WHERE 
          minute > NOW() - '1 DAYS':: INTERVAL
        GROUP BY 
          1,
          2,
          3
        UNION
        SELECT 
          p.contract_address,
          decimals,
          p.symbol,
          AVG(median_price) AS price
        FROM 
          dex."dex_token_prices" p
          LEFT JOIN erc20."tokens" t ON t.contract_address = p.contract_address
        WHERE 
          hour > NOW() - '1 DAYS':: INTERVAL
        GROUP BY 
          1,
          2,
          3
        UNION
        SELECT 
          p.contract_address,
          decimals,
          t.symbol,
          AVG(median_price) AS price
        FROM 
          dex."view_token_prices" p
          INNER JOIN erc20."tokens" t ON t.contract_address = p.contract_address
        WHERE 
          hour > NOW() - '1 DAYS':: INTERVAL
        GROUP BY 
          1,
          2,
          3
      ) p
    WHERE 
      contract_address IS NOT NULL
      AND decimals IS NOT NULL
      AND symbol IS NOT NULL
      AND price IS NOT NULL
    GROUP BY 
      1,
      2,
      3
  ),
  holdings AS (
    SELECT 
      wallet,
      contract_address,
      SUM(amount) AS amount
    FROM 
      (
        SELECT 
          "from" AS wallet,
          contract_address,
          (-1) * value AS amount
        FROM 
          erc20."ERC20_evt_Transfer"
        WHERE 
          "from" IN (
            '\x841AD0AbAb2D33520ca236A2F5D8b038adDc12BA',
            '\x1d11e78148849200f3e937f31e8A9F66433E69f8',
            '\x31519051d7477617CC5e52dc44c42B552c5C2aA9',
            '\x63C2c6BC822CaC9DE857193ED42Edf3AD0Ba5243',
            '\x5368B653B97d9C454984c92eef25584eCC347Ae9',
            '\x2a03278590cd1962De28F9AbC855CF3774fe3eb6',
            '\x40aE1F6D9F44Ea53f29EbB8C95B21185B3e0F39E',
            '\x8B600c7Ef1D97225860a7996b63c5b8b116182d5',
            '\x59907e47870a425d5Ec5495fD79e144d6cf332ce',
            '\xf9Bc09bF1771676eD9cB8bB130c1493c5dcBCDe4',
            '\x3bbdD6E34d4476Af80D294191512A1acE20De0F1',
            '\xa688d8b99b71C5F3bb6b42a3874Fa315762Dbe08',
            '\xBAfe6495E9BCBB78F3534a60980c3AaDbA74157B',
            '\x5E527fAEeF590BEF6192c493D217017f7d26DD61',
            '\x197962Fe09069Dea9d9276df0d9A3B75308aC94f',
            '\x7CA22EeaBB8C6db237E0c20148b9bfc6E2CCb708',
            '\xc69eC94F3dcE57B622D790E773899bc1d11A8074',
            '\x304160997E2D06fbfc0f54a8a714DC4cDf7B9E5F',
            '\xCD133D337eAD9C2AC799eC7524A1e0f8Aa30c3b1',
            '\xcd0b67a61E5e8F4616c19e421e929813B6D947df',
            '\x17d2B1B51fb36eF6f8e397feEE9e0C98Ad8EAB60',
            '\x2aB3d2E7C32b544B9E77d339D568A91eA1A2885d',
            '\xa5f19Da3281df2C88576d4461B3894A1983E1FB6',
            '\xaAA94eC1d5C58493257FA6811503e5CD5aa02410',
            '\x50Bb3F2Dd2F7BE1f8DC1D63314C8E3fA4F23EB4A',
            '\x036228015972297b37aCb933BB924c0384b6BEd5',
            '\x5AADB54B463204059ACB58262EC8ed49EFbddbaa',
            '\x07b665347867f1E3CFFa85f6390Ae25B5a0Fe97c',
            '\x8eE4169C68d0983e8933714f9716526021ab8A21',
            '\x8AC77A87C8281D8f80Ba64afB47b64a03d81B90f',
            '\xD131F1BcDd547e067Af447dD3C36C99d6be9FdEB',
            '\x60d009f8F49bdbce08c8771D91AE88d3e5D60cD0',
            '\x13c773E643c072066E209B6843Bd992b691ad54D',
            '\xd458Cb00aA70B4664177f9657E3F9A1021656219',
            '\x34B1987Af70A43A0647860Bdda720bA3664740E8',
            '\xBF861d09615543c419c749Ea8cBEB720E3B3E3ad',
            '\xDbf7E19a4FbCA4a2cD8820ca8A860C41fEadda90',
            '\xDCD072638a7827895BB12F1075831Da584c7b520',
            '\x1Cf693eceEbEee99aD60e82973E2d4829C801335',
            '\x3985857F2C9373f285CF196dfe07522ced5B44E0',
            '\xBEc0BA5D7E663955911F27E6C3DA80019FB8cD35',
            '\x11A7DCF5beb6c04e6aE72c74870c6ca3F0D1AFd9'
          )
        UNION
        SELECT 
          "to" AS wallet,
          contract_address,
          value AS amount
        FROM 
          erc20."ERC20_evt_Transfer"
        WHERE 
          "to" IN (
            '\x841AD0AbAb2D33520ca236A2F5D8b038adDc12BA',
            '\x1d11e78148849200f3e937f31e8A9F66433E69f8',
            '\x31519051d7477617CC5e52dc44c42B552c5C2aA9',
            '\x63C2c6BC822CaC9DE857193ED42Edf3AD0Ba5243',
            '\x5368B653B97d9C454984c92eef25584eCC347Ae9',
            '\x2a03278590cd1962De28F9AbC855CF3774fe3eb6',
            '\x40aE1F6D9F44Ea53f29EbB8C95B21185B3e0F39E',
            '\x8B600c7Ef1D97225860a7996b63c5b8b116182d5',
            '\x59907e47870a425d5Ec5495fD79e144d6cf332ce',
            '\xf9Bc09bF1771676eD9cB8bB130c1493c5dcBCDe4',
            '\x3bbdD6E34d4476Af80D294191512A1acE20De0F1',
            '\xa688d8b99b71C5F3bb6b42a3874Fa315762Dbe08',
            '\xBAfe6495E9BCBB78F3534a60980c3AaDbA74157B',
            '\x5E527fAEeF590BEF6192c493D217017f7d26DD61',
            '\x197962Fe09069Dea9d9276df0d9A3B75308aC94f',
            '\x7CA22EeaBB8C6db237E0c20148b9bfc6E2CCb708',
            '\xc69eC94F3dcE57B622D790E773899bc1d11A8074',
            '\x304160997E2D06fbfc0f54a8a714DC4cDf7B9E5F',
            '\xCD133D337eAD9C2AC799eC7524A1e0f8Aa30c3b1',
            '\xcd0b67a61E5e8F4616c19e421e929813B6D947df',
            '\x17d2B1B51fb36eF6f8e397feEE9e0C98Ad8EAB60',
            '\x2aB3d2E7C32b544B9E77d339D568A91eA1A2885d',
            '\xa5f19Da3281df2C88576d4461B3894A1983E1FB6',
            '\xaAA94eC1d5C58493257FA6811503e5CD5aa02410',
            '\x50Bb3F2Dd2F7BE1f8DC1D63314C8E3fA4F23EB4A',
            '\x036228015972297b37aCb933BB924c0384b6BEd5',
            '\x5AADB54B463204059ACB58262EC8ed49EFbddbaa',
            '\x07b665347867f1E3CFFa85f6390Ae25B5a0Fe97c',
            '\x8eE4169C68d0983e8933714f9716526021ab8A21',
            '\x8AC77A87C8281D8f80Ba64afB47b64a03d81B90f',
            '\xD131F1BcDd547e067Af447dD3C36C99d6be9FdEB',
            '\x60d009f8F49bdbce08c8771D91AE88d3e5D60cD0',
            '\x13c773E643c072066E209B6843Bd992b691ad54D',
            '\xd458Cb00aA70B4664177f9657E3F9A1021656219',
            '\x34B1987Af70A43A0647860Bdda720bA3664740E8',
            '\xBF861d09615543c419c749Ea8cBEB720E3B3E3ad',
            '\xDbf7E19a4FbCA4a2cD8820ca8A860C41fEadda90',
            '\xDCD072638a7827895BB12F1075831Da584c7b520',
            '\x1Cf693eceEbEee99aD60e82973E2d4829C801335',
            '\x3985857F2C9373f285CF196dfe07522ced5B44E0',
            '\xBEc0BA5D7E663955911F27E6C3DA80019FB8cD35',
            '\x11A7DCF5beb6c04e6aE72c74870c6ca3F0D1AFd9'
          )
      ) x
    GROUP BY 
      1,
      2
  )
SELECT 
  AVG(usd_holdings) AS avg_holding,
  PERCENTILE_CONT(0.5) WITHIN GROUP(
    ORDER BY 
      usd_holdings
  ) AS med_holding
FROM 
  (
    SELECT 
      wallet,
      SUM(usd_holdings) AS usd_holdings
    FROM 
      (
        SELECT 
          wallet,
          symbol,
          h.contract_address,
          -- calculate usd holdings by multiplying amount with price and dividing by 10^decimals
          amount * price / 10 ^ decimals AS usd_holdings
        FROM 
          holdings h
          LEFT JOIN price p ON h.contract_address = p.contract_address
        WHERE 
          amount > 0
      ) h
    WHERE 
      usd_holdings IS NOT NULL
    GROUP BY 
      1
  ) x