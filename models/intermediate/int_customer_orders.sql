with orders as (
    select * from {{ ref('int_orders_enriched') }}
),

aggregated as (
    select
        customer_id,
        count(order_id)                             as total_orders,
        sum(case when is_completed then 1 else 0 end) as completed_orders,
        sum(case when is_cancelled then 1 else 0 end) as cancelled_orders,
        sum(case when is_refunded  then 1 else 0 end) as refunded_orders,
        min(order_date)                             as first_order_date,
        max(order_date)                             as last_order_date,
        sum(case when is_completed
            then order_total else 0 end)            as lifetime_value,
        avg(case when is_completed
            then order_total end)                   as avg_order_value,
        datediff('day',
            min(order_date),
            max(order_date))                        as customer_lifespan_days
    from orders
    group by customer_id
)

select * from aggregated