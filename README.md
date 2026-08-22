### Credit Card Observability

This project was made to gain transparency and trend analysis into the distribution of spending from my credit card statements. Each raw credit card statement is first uploaded to a GCS bucket, then landed into bigquery where it is then cleaned, transformed, and processing using DBT. The final marts table contains each transaction's date, type, merchant, amount, and category which is then pulled into a PowerBI report and visualized.

Note that the raw data and PowerBI model have been obfuscated for privacy reasons.
