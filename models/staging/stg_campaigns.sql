with source as (
    select * from {{ source('raw', 'raw_campaigns') }}
),

renamed as (
    select
        campaign_id,
        campaign_name,
        lower(channel)                          as channel,
        budget,
        start_date,
        end_date,
        datediff('day', start_date, end_date)   as duration_days,
        target_country,
        lower(status)                           as status
    from source
)

select * from renamed