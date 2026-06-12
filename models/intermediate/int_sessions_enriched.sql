with sessions as (
    select * from {{ ref('stg_sessions') }}
),

campaigns as (
    select campaign_id, campaign_name, channel as campaign_channel
    from {{ ref('stg_campaigns') }}
),

final as (
    select
        s.session_id,
        s.customer_id,
        s.session_date,
        s.channel,
        s.pages_viewed,
        s.duration_sec,
        s.duration_min,
        s.converted,
        s.device,
        c.campaign_name,
        c.campaign_channel,
        case
            when s.duration_min < 1   then 'rebond'
            when s.duration_min < 5   then 'courte'
            when s.duration_min < 15  then 'moyenne'
            else                           'longue'
        end                                         as session_quality
    from sessions s
    left join campaigns c on s.campaign_id = c.campaign_id
)

select * from final