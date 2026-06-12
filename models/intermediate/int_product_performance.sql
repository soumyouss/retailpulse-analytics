with order_items as (
    select * from {{ ref('stg_order_items') }}
),

orders as (
    select order_id, is_completed, order_date
    from {{ ref('stg_orders') }}
),

products as (
    select * from {{ ref('stg_products') }}
),

joined as (
    select
        oi.product_id,
        p.product_name,
        p.category,
        p.cost_price,
        p.sell_price,
        p.margin_pct,
        p.stock_status,
        count(oi.item_id)                           as total_order_lines,
        sum(oi.quantity)                            as total_qty_sold,
        sum(oi.line_total)                          as total_revenue,
        sum(oi.line_total - p.cost_price
            * oi.quantity)                          as total_gross_profit,
        avg(oi.discount)                            as avg_discount
    from order_items oi
    left join orders  o on oi.order_id   = o.order_id
    left join products p on oi.product_id = p.product_id
    where o.is_completed = true
    group by
        oi.product_id, p.product_name, p.category,
        p.cost_price, p.sell_price, p.margin_pct, p.stock_status
)

select * from joined