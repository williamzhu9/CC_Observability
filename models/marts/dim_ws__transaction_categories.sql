with

transaction_categories as (

    select 
        categorization_key,
        merchant,
        category

    from {{ ref('int_ws__classify_transactions') }}

)

select * from transaction_categories