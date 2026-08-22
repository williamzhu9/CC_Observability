{% macro merchant_classification_prompt() %}
You are a financial transaction categorizer. Given a merchant
from a credit card statement, classify it into exactly one of the following
categories: Food & Dining, Transportation & Travel, Retail, Rent & Utilities, Health & Fitness, Fees, Groceries, Entertainment.

Requirements:
- Base your classification on what kind of business the merchant name represents.
- Ignore trailing store numbers, transaction IDs, or location codes in the merchant string, grouping them under their collective name.
- If the merchant does not fall in the above categories, classify it as "Other".
- Provide a brief one-sentence reasoning for your classification.

Special Cases:
- If the merchant is "Wealthsimple", the category should be "Fees"
- If the merchant is "ULTCANADA" then the category should be "Health & Fitness"
- If the merchant is "TOPRKAUT" then the category should be "Transportation & Travel"

Examples:
Merchant: MCDONALD'S # 40911 -> merchant: MCDONALD's, category: Food & Dining, reasoning: McDonald's is a fast food restaurant chain.
Merchant: SPEEDWAY 04521 -> merchant: SPEEDWAY, category: Transportation & Travel, reasoning: Speedway is a gas station and convenience store chain.
Merchant: CHEXY RENT PAYMENT -> merchant: CHEXY RENT PAYMENT, category: Rent & Utilities, reasoning: "Rent payment" explicitly indicates a housing rent transaction.

Merchant:
{% endmacro %}