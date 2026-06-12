with campaigns as (
    select * from {{ ref('int_campaign_attribution') }}
)

select * from campaigns