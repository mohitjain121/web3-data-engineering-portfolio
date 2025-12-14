/* Description: Extracts bet statistics from PancakeSwap prediction events. */

with bet as (
    select 
        * , 
        'bear' as bet_type 
    from 
        pancakeswap_v2."PancakePredictionV2_evt_BetBear"
    
    union all
    
    select 
        * , 
        'bull' as bet_type 
    from 
        pancakeswap_v2."PancakePredictionV2_evt_BetBull"
)
select 
    count(DISTINCT evt_tx_hash) as num_bets, 
    count(distinct sender) as num_users, 
    round(sum(amount)/'1000000000000000000') as "total_amt(BNB)"
from 
    bet
where 
    evt_block_time >= '2022-01-01 00:00:00'