with customers as (
    select * from {{ ref('stg_customers') }}
),

orders as (
    select * from {{ ref('int_customer_orders') }}
),

final as (
    select
        c.customer_id,
        c.first_name,
        c.last_name,
        c.email,
        c.phone,
        c.country_code,
        c.city,
        c.segment,
        c.created_at,
        c.is_active,
        c.has_email,

        coalesce(o.total_orders,      0)            as total_orders,
        coalesce(o.completed_orders,  0)            as completed_orders,
        coalesce(o.cancelled_orders,  0)            as cancelled_orders,
        coalesce(o.lifetime_value,    0)            as lifetime_value,
        coalesce(o.avg_order_value,   0)            as avg_order_value,
        o.first_order_date,
        o.last_order_date,
        o.customer_lifespan_days,

        case
            when o.total_orders is null      then 'prospect'
            when o.completed_orders = 0      then 'perdu'
            when o.completed_orders = 1      then 'nouveau'
            when o.completed_orders between 2
                 and 4                       then 'regulier'
            else                                  'vip'
        end                                         as customer_segment

    from customers c
    left join orders o on c.customer_id = o.customer_id
)

select * from final