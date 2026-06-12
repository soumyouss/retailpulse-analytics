with products as (
    select * from {{ ref('stg_products') }}
),

performance as (
    select * from {{ ref('int_product_performance') }}
),

final as (
    select
        p.product_id,
        p.product_name,
        p.category,
        p.cost_price,
        p.sell_price,
        p.gross_margin,
        p.margin_pct,
        p.stock_qty,
        p.stock_status,
        p.is_active,

        coalesce(pf.total_qty_sold,    0)           as total_qty_sold,
        coalesce(pf.total_revenue,     0)           as total_revenue,
        coalesce(pf.total_gross_profit,0)           as total_gross_profit,
        coalesce(pf.avg_discount,      0)           as avg_discount,
        coalesce(pf.total_order_lines, 0)           as total_order_lines

    from products p
    left join performance pf on p.product_id = pf.product_id
)

select * from final