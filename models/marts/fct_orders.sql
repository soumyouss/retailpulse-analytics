{{
    config(
        materialized='incremental',
        unique_key='order_id'
    )
}}

with orders as (
    select * from {{ ref('int_orders_enriched') }}

    {% if is_incremental() %}
        where order_date > (select max(order_date) from {{ this }})
    {% endif %}
)

select
    order_id,
    customer_id,
    campaign_id,
    order_date,
    order_month,
    order_year,
    order_month_num,
    status,
    payment_method,
    channel,
    shipping_cost,
    is_completed,
    is_cancelled,
    is_refunded,
    country_code,
    city,
    segment,
    nb_items,
    order_total,
    total_qty,
    total_with_shipping,
    case
        when is_completed then order_total
        else 0
    end                                             as revenue

from orders