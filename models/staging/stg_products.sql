with source as (
    select * from {{ source('raw', 'raw_products') }}
),

renamed as (
    select
        product_id,
        product_name,
        lower(category)                         as category,
        cost_price,
        sell_price,
        round(sell_price - cost_price, 2)       as gross_margin,
        round((sell_price - cost_price)
              / nullif(sell_price, 0) * 100, 2) as margin_pct,
        stock_qty,
        is_active,
        case
            when stock_qty = 0   then 'rupture'
            when stock_qty <= 10 then 'stock_faible'
            else                      'disponible'
        end                                     as stock_status
    from source
)

select * from renamed