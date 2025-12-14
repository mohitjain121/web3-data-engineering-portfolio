/*
Description: This query calculates daily transaction metrics for specific blockchains and wallets.
*/

with txns as 
(
    select
        date(evt_block_time) as day,
        blockchain,
        count(
            case 
                when 
                    evt_block_time >= date('2023-03-14') 
                    and evt_block_time <= date('2023-03-20') 
                    and sender in (select address from query_{{wallets_query}})
                then 
                    evt_tx_hash 
            end
        ) as quest_dates,
        count(evt_tx_hash) as transaction_count,
        count(distinct sender) as dau,
        count(
            case 
                when sender in (select address from query_{{wallets_query}}) 
                then 
                    sender 
            end
        ) as l3_quest_impact
    from 
        query_{{txns_table_query}}
    where 
        evt_block_time >= date('2023-01-01')
        and blockchain in ('arbitrum', 'optimism', 'polygon')
    group by 
        1, 
        2
)

select
    day,
    blockchain,
    transaction_count,
    dau,
    l3_quest_impact,
    quest_dates,
    avg(transaction_count) over (order by day rows between 29 preceding and current row) as ma_30_day_txn,
    avg(dau) over (order by day rows between 29 preceding and current row) as ma_30_day_dau
from 
    txns
group by 
    1, 
    2, 
    3, 
    4, 
    5, 
    6
order by 
    1 asc