with source as (
    select * from {{ source('raw', 'raw_customers') }}
),

renamed as (
    select
        customer_id,
        first_name,
        last_name,
        lower(email)                            as email,
        phone,
        upper(country)                          as country_code,
        city,
        segment,
        created_at,
        is_active,
        case
            when email is null then false
            else true
        end                                     as has_email
    from source
)

select * from renamed