with 

raw_data as (

    select 
      * 
    from 
      {{ source('gsheets', 'budget_raw') }}

),

standardized as (

    select
        Category                                        as budget_category,
        Item                                            as item,
        ROUND(cast(Amount as numeric), 2)               as amount,
        ROUND(cast(Amount__BI_Weekly_ as numeric), 2)   as amount_bi_weekly,
        Payment_Account                                 as payment_account,   
        Holding_Account                                 as holding_account,

    from raw_data

),

final as (
    
    select
        {{ dbt_utils.generate_surrogate_key([
            'budget_category', 
            'item',
            'amount',
            'amount_bi_weekly',
            'payment_account',
            'holding_account']) 
        }} as budget_key,
        budget_category,
        item,
        amount,
        amount_bi_weekly,
        payment_account,   
        holding_account

    from
        standardized
)

select * from final