with

cc_statements as (

    select * from {{ ref('stg_ws__cc_statements') }}

),

transaction_categories as (

    select * from {{ ref('dim_ws__transaction_categories') }}

),

final as (

    select
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