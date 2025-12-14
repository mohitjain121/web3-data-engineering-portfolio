/* Description: Daily bet statistics for PancakeSwap V2 */
with bet as (
    select 
        *, 
        'bear' as bet_type, 
        date_trunc('day', evt_block_time) as dt 
    from 
        pancakeswap_v2."PancakePredictionV2_evt_BetBear"
    union all
    select 
        *, 
        'bull' as bet_type, 
        date_trunc('day', evt_block_time) as dt 
    from 
        pancakeswap_v2."PancakePredictionV2_evt_BetBull"
)
select 
    dt, 
    bet_type, 
    count(1) as num_bets, 
    count(distinct sender) as num_users, 
    round(sum(amount)/'1000000000000000000') as "total_amt(BNB)"
from 
    bet
where 
    evt_block_time >= '2022-01-01 00:00:00' 
group by 
    dt, 
    bet_type
order by 
    dt desc