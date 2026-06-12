with sessions as (
    select * from {{ ref('int_sessions_enriched') }}
)

select
    session_id,
    customer_id,
    session_date,
    channel,
    device,
    pages_viewed,
    duration_min,
    converted,
    campaign_name,
    session_quality
from sessions