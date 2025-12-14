/* Description: Calculate total deposits, withdrawals, and balance change for a specific Solana address. */

SELECT
    block_date,
    SUM(CASE WHEN balance_change >= 0 THEN balance_change END) AS total_deposits,
    COUNT(CASE WHEN balance_change >= 0 THEN balance_change END) AS count_deposits,
    SUM(CASE WHEN balance_change < 0 THEN balance_change END) AS total_withdrawals,
    COUNT(CASE WHEN balance_change < 0 THEN balance_change END) AS count_withdrawals,
    SUM(balance_change) AS balance_change
FROM (
    SELECT
        block_date,
        address,
        balance_change / 1e9 AS balance_change,
        tx_id
    FROM 
        solana.account_activity
    WHERE 
        address = '92tjqyfq7bhfrd3as53ngw4pmmwllhqhpdi69s1nx9x'
        AND block_date > '2022-06-01'
        AND tx_id NOT IN (
            '4xbcrxy9gqx47vfxwpjaqp9sabcisn6prpwu1xfufkvdtiniajpcgbwscaxpsuj4ywllkq4a9hixritrumyzjirp',
            '3zcndwia3y6jamhd6aatzuaffkuqmkrju6taczqd14d7uhtjp94zfyqmevaznjgsvhmqmqslnqu7pstkutb2',
            '5f7gsrxwv9bzimjabweekkalnrupfeaj4mpl5f1ehhlt3nrqbefnvcf6uar5jeh6gm2fsyx68rtzqebl2gmddk',
            'ufj5nhfpzz3jejegjcazrgezfszlmev9g9a1dopw2mqn8ikwrpjfk5ixawmgqqfgos5rszijjnmtwq3sw',
            'r1fkcvrjbhcdeevcvuxqqndae6xavcntzor dop8yj1i4rwnvskqpumbtnuw4nrsqbscxp9fzl6apf4a'
        )
        AND tx_success = true
) x
GROUP BY 1
ORDER BY 1 DESC;