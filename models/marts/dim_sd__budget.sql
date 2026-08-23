WITH

budget AS (

    SELECT 
        * 
        
    FROM 
        {{ ref('stg_gs__budget') }}

),

budget_categories AS (

    SELECT
        *

    FROM 
        {{ ref('budget_categories') }}

),

final as (

    SELECT
        b.budget_key,
        b.budget_category,
        b.item,
        b.amount,
        b.amount_bi_weekly,
        b.payment_account,   
        b.holding_account,
        bc.transaction_category

    FROM 
        budget b

    LEFT JOIN 
        budget_categories bc

    ON 
        b.item = bc.budget_item
        AND 
        b.budget_category != 'Savings'

)

select * from final