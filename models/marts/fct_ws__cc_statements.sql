{{ config(
    materialized='incremental',
    incremental_strategy='merge',
    unique_key='transaction_key',
    on_schema_change='fail'
) }}

with

cc_statements as (

    select * from {{ ref('stg_ws__cc_statements') }} as staged

    {% if is_incremental() %}
    -- Check keys rather than dates so statements loaded out of order are included.
    where not exists (
        select 1
        from {{ this }} as existing
        where existing.transaction_key = staged.transaction_key
    )
    {% endif %}

),

transaction_categories as (

    select * from {{ ref('dim_ws__transaction_categories') }}

),

final as (

    select
        cc_statements.transaction_key,
        cc_statements.transaction_date,
        cc_statements.post_date,
        cc_statements.transaction_type,
        cc_statements.merchant,
        cc_statements.amount_CAD,
        cc_statements.currency,
        transaction_categories.category as transaction_category

    from cc_statements
    left join transaction_categories
        on cc_statements.merchant = transaction_categories.merchant

    ORDER BY
        
        cc_statements.transaction_date desc

)

select * from final
