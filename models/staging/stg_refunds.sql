with source as (
    select * from {{ source('raw', 'raw_refunds') }}
),

renamed as (
    select
        refund_id,
        order_id,
        refund_date,
        refund_amount,
        lower(reason)                           as reason
    from source
)

select * from renamed