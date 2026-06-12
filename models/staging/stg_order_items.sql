with source as (
    select * from {{ source('raw', 'raw_order_items') }}
),

renamed as (
    select
        item_id,
        order_id,
        product_id,
        quantity,
        unit_price,
        discount,
        round(unit_price * (1 - discount), 2)          as net_price,
        round(quantity * unit_price * (1 - discount), 2) as line_total
    from source
)

select * from renamed