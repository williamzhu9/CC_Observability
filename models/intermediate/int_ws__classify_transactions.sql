{{
    config(
        materialized = 'incremental',
        unique_key = 'categorization_key',
        schema = 'int',
        on_schema_change='append_new_columns'
    )
}}

with distinct_merchants as (

    select distinct
        merchant,

    from {{ ref('stg_ws__cc_statements') }}

    where
        merchant IS NOT NULL
    {% if is_incremental() %}
        AND
        merchant not in (select merchant from {{ this }})
    {% endif %}

),

categorized as (

    select
        {{ dbt_utils.generate_surrogate_key([
            'merchant', 
            'category']) 
        }} as categorization_key,
        merchant,
        category,
        reasoning

    from AI.GENERATE_TABLE(
        MODEL `cc-statement-observability.ml_models.gemini_35_flash_lite`,
        (
            select
                merchant,
                concat(
                    '''{{ merchant_classification_prompt() }}''',
                    ' ',
                    merchant
                ) as prompt
            from distinct_merchants
        ),
        STRUCT(
            'category STRING, reasoning STRING' as output_schema,
            0.0 as temperature
        )
    )

)

select * from categorized