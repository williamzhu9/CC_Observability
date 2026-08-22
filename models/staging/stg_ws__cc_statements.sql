with 

source as (

    select * from {{ source('cc_statement_observability', 'cc_statements_raw') }}

),

deduped as (
    select
        *,
        row_number() over (
            partition by transaction_date, post_date, type, details, amount, currency
            order by transaction_date
        ) as dedup_rank
    from source
),

renamed as (

    select
        {{ dbt_utils.generate_surrogate_key([
            'transaction_date', 
            'post_date',
            'type',
            'details',
            'amount',
            'currency',
            'dedup_rank']) 
        }} as transaction_key,
        transaction_date,
        post_date,
        type                            as transaction_type,
        details                         as merchant,
        amount                          as amount_CAD,
        currency

    from deduped

),

replace_null_merchants as (

    select
        transaction_key,
        transaction_date,
        post_date,
        transaction_type,
        CASE
            WHEN merchant = '' AND transaction_type = 'Monthly fee' THEN 'Wealthsimple'
            WHEN merchant = '' THEN 'Unknown Merchant'
            ELSE merchant
        END as merchant,
        amount_CAD,
        currency

    from renamed

)

select * from replace_null_merchants