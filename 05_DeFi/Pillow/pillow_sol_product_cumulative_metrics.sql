/* Description: Calculate cumulative deposits, withdrawals, and net deposits for a specific Solana address. */

SELECT
    block_date,
    SUM(total_deposits) OVER (ORDER BY block_date ASC) AS cum_deposits,
    SUM(count_deposits) OVER (ORDER BY block_date ASC) AS cum_count_deposits,
    SUM(total_withdrawals) OVER (ORDER BY block_date ASC) AS cum_withdrawals,
    SUM(count_withdrawals) OVER (ORDER BY block_date ASC) AS cum_count_withdrawals,
    SUM(net_deposits) OVER (ORDER BY block_date ASC) AS net_deposits
FROM (
    SELECT
        block_date,
        SUM(CASE WHEN balance_change >= 0 THEN balance_change END) AS total_deposits,
        COUNT(CASE WHEN balance_change >= 0 THEN balance_change END) AS count_deposits,
        SUM(CASE WHEN balance_change < 0 THEN balance_change END) AS total_withdrawals,
        COUNT(CASE WHEN balance_change < 0 THEN balance_change END) AS count_withdrawals,
        SUM(balance_change) AS balance_change,
        SUM(CASE WHEN balance_change >= 0 THEN 1 ELSE 0 END) AS net_deposits
    FROM (
        SELECT
            block_date,
            address,
            balance_change / 1e9 AS balance_change,
            tx_id
        FROM
            solana.account_activity
        WHERE 
            address = '92tjqyfq7bhfrd3as53ngw4pmmwllhqhpdii69s1nx9x'
            AND block_date > '2022-06-01'
            AND tx_id NOT IN 
                (
                '4xbcrxy9gqx47vfxwpjaqp9sabcisn6prpwu1xfufkvdtlniahpcgbwscaxpusu4ywllkq4a9hixritrumyzjirp',
                '3zcndwia3y6jamhd6aatzuaffkuqmkrju6taczqd14d7uhtjp94zfyqmevaznjgsvhmqm4sllu7pstkubt2',
                '5f7gsrxwv9bzimjabweekkalnrupfeaj4mpl5f1ehhlt3nrqbefnvcf6uar5jeh6gm2fsyxnrtzqebl2gmddk',
                'ufjumnhfpzzy3jejegjcazrgezfzlmeveh9g9a1dopw2mqn8ikwrpjfk5ixawmgqqfgos5rszijjnmtwq3sw',
                'r1fkcvrjbhcdeevcvuxqqndae6xavcntzor dop8yj1i4rwnvskjqpu mbtnuw4nrsqbscxp9fzl6apjm4a'
                )
            AND tx_success = true
    ) x
    GROUP BY 1
)
ORDER BY 1 DESC;