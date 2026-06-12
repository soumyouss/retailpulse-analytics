with orders as (
    select * from {{ ref('stg_orders') }}
),

sessions as (
    select * from {{ ref('stg_sessions') }}
),

campaigns as (
    select * from {{ ref('stg_campaigns') }}
),

order_attribution as (
    select
        o.campaign_id,
        count(o.order_id)                           as total_orders,
        sum(case when o.is_completed
            then 1 else 0 end)                      as completed_orders,
        sum(case when o.is_completed
            then o.shipping_cost else 0 end)        as attributed_shipping
    from orders o
    where o.campaign_id is not null
    group by o.campaign_id
),

session_attribution as (
    select
        campaign_id,
        count(session_id)                           as total_sessions,
        sum(case when converted then 1 else 0 end)  as conversions,
        avg(duration_min)                           as avg_session_duration
    from sessions
    where campaign_id is not null
    group by campaign_id
),

final as (
    select
        c.campaign_id,
        c.campaign_name,
        c.channel,
        c.budget,
        c.duration_days,
        c.status,

        coalesce(oa.total_orders,     0)            as total_orders,
        coalesce(oa.completed_orders, 0)            as completed_orders,
        coalesce(sa.total_sessions,   0)            as total_sessions,
        coalesce(sa.conversions,      0)            as conversions,
        coalesce(sa.avg_session_duration, 0)        as avg_session_duration,

        round(coalesce(sa.conversions, 0)
            / nullif(sa.total_sessions, 0) * 100, 2) as conversion_rate,
        round(c.budget
            / nullif(oa.completed_orders, 0), 2)    as cost_per_order

    from campaigns c
    left join order_attribution  oa on c.campaign_id = oa.campaign_id
    left join session_attribution sa on c.campaign_id = sa.campaign_id
)

select * from final