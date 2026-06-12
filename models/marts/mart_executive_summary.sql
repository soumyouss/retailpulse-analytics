with orders as (
    select * from {{ ref('fct_orders') }}
),

sessions as (
    select * from {{ ref('fct_sessions') }}
),

monthly as (
    select
        order_year,
        order_month_num,
        order_month,
        count(order_id)                             as total_orders,
        sum(case when is_completed
            then 1 else 0 end)                      as completed_orders,
        sum(case when is_cancelled
            then 1 else 0 end)                      as cancelled_orders,
        sum(revenue)                                as monthly_revenue,
        avg(case when is_completed
            then order_total end)                   as avg_basket,
        count(distinct customer_id)                 as unique_customers

    from orders
    group by order_year, order_month_num, order_month
),

session_monthly as (
    select
        year(session_date)                          as session_year,
        month(session_date)                         as session_month,
        count(session_id)                           as total_sessions,
        sum(case when converted
            then 1 else 0 end)                      as conversions,
        round(sum(case when converted
            then 1 else 0 end)
            / nullif(count(session_id), 0) * 100, 2) as conversion_rate
    from sessions
    group by session_year, session_month
),

final as (
    select
        m.order_year                                as year,
        m.order_month_num                           as month,
        m.order_month,
        m.total_orders,
        m.completed_orders,
        m.cancelled_orders,
        m.monthly_revenue,
        m.avg_basket,
        m.unique_customers,
        coalesce(s.total_sessions,  0)              as total_sessions,
        coalesce(s.conversions,     0)              as conversions,
        coalesce(s.conversion_rate, 0)              as conversion_rate,
        round(m.cancelled_orders
            / nullif(m.total_orders, 0) * 100, 2)  as cancellation_rate

    from monthly m
    left join session_monthly s
           on m.order_year      = s.session_year
          and m.order_month_num = s.session_month
)

select * from final
order by year, month