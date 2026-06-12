with source as (
    select * from {{ source('raw', 'raw_orders') }}
),

renamed as (
    select
        order_id,
        customer_id,
        campaign_id,
        order_date,
        date_trunc('month', order_date)         as order_month,
        year(order_date)                        as order_year,
        month(order_date)                       as order_month_num,
        lower(status)                           as status,
        lower(payment_method)                   as payment_method,
        lower(channel)                          as channel,
        shipping_cost,
        case
            when lower(status) = 'completed' then true
            else false
        end                                     as is_completed,
        case
            when lower(status) = 'cancelled' then true
            else false
        end                                     as is_cancelled,
        case
            when lower(status) = 'refunded'  then true
            else false
        end                                     as is_refunded
    from source
)

select * from renamed