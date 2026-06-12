with source as (
    select * from {{ source('raw', 'raw_sessions') }}
),

renamed as (
    select
        session_id,
        customer_id,
        session_date,
        lower(channel)                          as channel,
        campaign_id,
        pages_viewed,
        duration_sec,
        round(duration_sec / 60.0, 1)           as duration_min,
        converted,
        lower(device)                           as device
    from source
)

select * from renamed