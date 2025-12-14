/* Description: Calculate total and daily token and dollar rewards for each token pair. */

WITH 
  token_pair_names AS (
    VALUES 
      ('WEYU-USDC', 'WEYU', 'USDC', '8', '6', '4yaWcN2mkU41PfS83TJnUZkumkPZmUAjLzhdngqy3Lni', 
       'EHaEBhYHWA7HSphorXXosysJem6qF4agccoqDqQKCUge', 'EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v', 
       'EHaEBhYHWA7HSphorXXosysJem6qF4agccoqDqQKCUge', 'EEtN4EResnYBX4ukuqhWwpYcMAHrQHQVMxKFsUAbNZwP', 
       '1657620000', '1660212000', '2411265432'),
      ('WEYU-USDC', 'WEYU', 'USDC', '8', '6', '4yaWcN2mkU41PfS83TJnUZkumkPZmUAjLzhdngqy3Lni', 
       'EHaEBhYHWA7HSphorXXosysJem6qF4agccoqDqQKCUge', 'EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v', 
       '4vqAHZgaQT6e1vGVhFjZVXGEejxJsiXpxsmjmw8LPtRK', 'ESmijm5eSCPp5w9rgLhu157VTSGEvYmvtYQQH1VjkmgF', 
       '1657620000', '1660212000', '643003858'),
      ('GARY-SOL', 'GARY', 'SOL', '9', '9', 'A5y26NWnFqeDmHsCQNScLhpHzz5CQVosZwE6AbNmvnPQ', 
       '8c71AvjQeKKeWRe8jtTGG1bJ2WiYXQdbjqFbUfhHgSVk', 'So11111111111111111111111111111111111111112', 
       '8c71AvjQeKKeWRe8jtTGG1bJ2WiYXQdbjqFbUfhHgSVk', 'EW2g5AuJNcmwYQ3HsEQgTc3Y7KL9WoUoHvy35vjowwUa', 
       '1657379820', '1659971820', '5787037'),
      ('ARB-USDC', 'ARB', 'USDC', '6', '6', 'Acyc5wVxgV6iFzqk5cmsABbjoVdr5CA5tfb4Y5LDzVuB', 
       '9tzZzEHsKnwFL1A3DyFJwj36KnZj3gZ7g4srWp9YTEoh', 'EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v', 
       '9tzZzEHsKnwFL1A3DyFJwj36KnZj3gZ7g4srWp9YTEoh', '4Wf2XmWGLLeDUh7DYHqX1XoRetNXgBEomY2AqpVxHp69', 
       '1658361540', '1666137540', '643004'),
      ('XTR-USDC', 'XTR', 'USDC', '8', '6', '6ecpT2Kp2UUWdhcK2q2iznJKBhqb6GV2ybHxBcF2L4Qi', 
       '6ABQdaTwRvmacto7aeRBGghS6Pxctd6cFGL8gDdwV1dd', 'EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v', 
       '6ABQdaTwRvmacto7aeRBGghS6Pxctd6cFGL8gDdwV1dd', 'GPK6Bp7UXvxitE5U1f3VMdjAhUqYWiwYV2xQyh9zUpB2', 
       '1659225600', '1667001600', '115740740'),
      ('GXE-USDC', 'GXE', 'USDC', '9', '6', '4M7aKwu4YiRJsx8rVNk8kYZZ7VcaKSzFdLjrwZ1kQtW9', 
       'DsVPH4mAppxKrmdzcizGfPtLYEBAkQGK4eUch32wgaHY', 'EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v', 
       'AAXng5czWLNtTXHdWEn9Ef7kXMXEaraHj2JQKo7ZoLux', 'Hqnw1uP4dMLyqdr7hFJr3pdZoKnUQghjSoViMJ8FY5Yf', 
       '1658376000', '1660968000', '115740740'),
      ('NARK-USDC', 'NARK', 'USDC', '9', '6', '6BNd469hESJyjBuxRsSXrMosoEoupshLxRFWsPMrQP2b', 
       'CYndQCN5WJL2iF4V42mZ5u8CHPAHCLz7wCXYwPd5hJ37', 'EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v', 
       'CYndQCN5WJL2iF4V42mZ5u8CHPAHCLz7wCXYwPd5hJ37', '7LRbswShCMrkA4ZXudoPYBXZQ3nE3vs3919CMpMyfgyz', 
       '1658444460', '1666220460', '128600823'),
      ('LRA-USDC', 'LRA', 'USDC', '9', '6', 'HVHUiaW5Kcd644e446TCBu9bdMB7LmSeMZPa5FjyEcW5', 
       'FMJotGUW16AzexRD3vXJQ94AL71cwrhtFaCTGtK1QHXm', 'EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v', 
       'FMJotGUW16AzexRD3vXJQ94AL71cwrhtFaCTGtK1QHXm', 'gnpwrf4hyEFcSwBicUaHRXg9SCBVvqoKMLCB67DATyG', 
       '1659109500', '1666885500', '1286008230'),
      ('MINECRAFT-USDC', 'MINECRAFT', 'USDC', '9', '6', 'BoNxnJbMCGXyBXVFgrZATaJpRttzL4AhHdev3Q9uqfkq', 
       'FTkj421DxbS1wajE74J34BJ5a1o9ccA97PkK6mYq9hNQ', 'EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v', 
       'FTkj421DxbS1wajE74J34BJ5a1o9ccA97PkK6mYq9hNQ', 'Cu8dLPQkaxmoEMgRTdctYWvezhshG74qH1Dn79qX1L9q', 
       '1657716900', '1665492900', '128600823'),
      ('USDT-USDC', 'USDT', 'USDC', '6', '6', '2EXiumdi14E9b8Fy62QcA5Uh6WdHS2b38wtSxp72Mibj', 
       'Es9vMFrzaCERmJfrF4H2FYD4KCoNkY11McCe8BenwNYB', 'EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v', 
       'CASHVDm2wsJXfhj6VWxb7GiMdoLc17Du7paH4bNr5woT', '7BF6MUxZm7qTKKhAKxkjWbNZJZ12hEn2RSqgnAa6khZn', 
       '1658665800', '1659270600', '117611'),
      ('USDT-USDC', 'USDT', 'USDC', '6', '6', '2EXiumdi14E9b8Fy62QcA5Uh6WdHS2b38wtSxp72Mibj', 
       'Es9vMFrzaCERmJfrF4H2FYD4KCoNkY11McCe8BenwNYB', 'EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v', 
       'PRT88RkA4Kg5z7pKnezeNH4mafTvtQdfFgpQTGRjz44', '6mRf2tXJX3c5n9PXtk9MtFJxeXBDjDdUQYuPEDLapjGp', 
       '1657978200', '1658583000', '70349'),
      ('USDT-USDC', 'USDT', 'USDC', '6', '6', '2EXiumdi14E9b8Fy62QcA5Uh6WdHS2b38wtSxp72Mibj', 
       'Es9vMFrzaCERmJfrF4H2FYD4KCoNkY11McCe8BenwNYB', 'EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v', 
       '3QuAYThYKFXSmrTcSHsdd7sAxaFBobaCkLy2DBYJLMDs', 'GzyvzkrHgbQ3oKMEmuURrDAijTMP5hVagZjueNQoynZK', 
       '1657979400', '1658584200', '0')
  ),
  prices AS (
    VALUES 
      ('EHaEBhYHWA7HSphorXXosysJem6qF4agccoqDqQKCUge', 'WEYU', '8', '0.0017'),
      ('4vqAHZgaQT6e1vGVhFjZVXGEejxJsiXpxsmjmw8LPtRK', 'WEDAO', '9', '0.0000269887005649718'),
      ('8c71AvjQeKKeWRe8jtTGG1bJ2WiYXQdbjqFbUfhHgSVk', '$GARY', '9', '0.36'),
      ('9tzZzEHsKnwFL1A3DyFJwj36KnZj3gZ7g4srWp9YTEoh', 'ARB', '6', '0.012'),
      ('6ABQdaTwRvmacto7aeRBGghS6Pxctd6cFGL8gDdwV1dd', 'XTR', '8', '0.0015'),
      ('AAXng5czWLNtTXHdWEn9Ef7kXMXEaraHj2JQKo7ZoLux', 'DGE', '9', '0.0148'),
      ('CYndQCN5WJL2iF4V42mZ5u8CHPAHCLz7wCXYwPd5hJ37', 'NARK', '9', '0.000155'),
      ('FMJotGUW16AzexRD3vXJQ94AL71cwrhtFaCTGtK1QHXm', 'LRA', '9', '0.000387'),
      ('FTkj421DxbS1wajE74J34BJ5a1o9ccA97PkK6mYq9hNQ', 'MINECRAFT', '9', '0.002414'),
      ('CASHVDm2wsJXfhj6VWxb7GiMdoLc17Du7paH4bNr5woT', 'CASH', '6', '0.00000585'),
      ('PRT88RkA4Kg5z7pKnezeNH4mafTvtQdfFgpQTGRjz44', 'PRT', '6', '0.00064075'),
      ('3QuAYThYKFXSmrTcSHsdd7sAxaFBobaCkLy2DBYJLMDs', 'wTYNA', '3', '13.82')
  )
SELECT 
    token_pair_name,
    reward_token,
    (reward_end_time - reward_open_time) * reward_per_second / POWER(10, token_decimals) AS total_token_rewards,
    (reward_end_time - reward_open_time) * price * reward_per_second / POWER(10, token_decimals) AS total_dollar_rewards,
    86400 * reward_per_second / POWER(10, token_decimals) AS daily_token_rewards,
    86400 * price * reward_per_second / POWER(10, token_decimals) AS daily_dollar_rewards
FROM 
    token_pair_names t
    LEFT JOIN prices p ON t.reward_mint = p.token_address
ORDER BY 
    4 DESC;