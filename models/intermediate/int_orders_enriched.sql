with orders as (
    select * from {{ ref('stg_orders') }}
),

customers as (
    select * from {{ ref('stg_customers') }}
),

order_items as (
    select
        order_id,
        count(item_id)                  as nb_items,
        sum(line_total)                 as order_total,
        sum(quantity)                   as total_qty
    from {{ ref('stg_order_items') }}
    group by order_id
),

final as (
    select
        o.order_id,
        o.customer_id,
        o.campaign_id,
        o.order_date,
        o.order_month,
        o.order_year,
        o.order_month_num,
        o.status,
        o.payment_method,
        o.channel,
        o.shipping_cost,
        o.is_completed,
        o.is_cancelled,
        o.is_refunded,

        c.first_name,
        c.last_name,
        c.email,
        c.country_code,
        c.city,
        c.segment,
        c.has_email,

        oi.nb_items,
        oi.order_total,
        oi.total_qty,
        coalesce(oi.order_total, 0)
            + coalesce(o.shipping_cost, 0)      as total_with_shipping

    from orders o
    left join customers c  on o.customer_id  = c.customer_id
    left join order_items oi on o.order_id   = oi.order_id
)

select * from final