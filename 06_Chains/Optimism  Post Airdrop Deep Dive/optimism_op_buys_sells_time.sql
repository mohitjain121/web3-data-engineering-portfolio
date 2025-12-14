/* Description: Calculate OP token trade statistics and moving averages. */

with op_trades as (
    select 
        date_trunc('DAY', block_time) as block_hour,
        (-1)*token_a_amount as trade_amount,
        tx_hash
    from 
        dex.trades
    where 
        token_a_address = '\x4200000000000000000000000000000000000042'
        and block_time >= now() - interval '35 days'
    union all
    select 
        date_trunc('DAY', block_time) as block_hour,
        token_b_amount as trade_amount,
        tx_hash
    from 
        dex.trades
    where 
        token_b_address = '\x4200000000000000000000000000000000000042'
        and block_time >= now() - interval '35 days'
),

op_price as (
    select 
        date_trunc('DAY', hour) as block_hour, 
        AVG(median_price) as price
    from 
        prices."approx_prices_from_dex_data"
    where 
        symbol = 'OP'
        and hour >= now() - interval '35 days'
    GROUP BY 
        1
),

op_trades_summary as (
    select 
        t.block_hour,
        count(distinct tx_hash) as trade_count,
        sum(trade_amount) as trade_amount,
        sum(trade_amount * p.price) as usd_trade_amount,
        avg(p.price) as price
    from 
        op_trades t
    inner join 
        op_price p on t.block_hour = p.block_hour
    group by 
        t.block_hour
    order by 
        t.block_hour
)

select 
    block_hour,
    trade_count,
    trade_amount,
    usd_trade_amount,
    price,
    sum(trade_count) over (order by block_hour) as accumulated_trade_count,
    sum(trade_amount) over (order by block_hour) as accumulated_trade_amount,
    sum(usd_trade_amount) over (order by block_hour) as accumulated_usd_trade_amount,
    avg(price) over (order by block_hour rows between 7 preceding and current row) as price_ma
from 
    op_trades_summary
order by 
    block_hour;