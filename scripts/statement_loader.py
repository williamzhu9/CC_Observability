"""
load_cc_statement.py

Uploads a local monthly CC statement CSV to GCS, then loads/appends it into
a continuously growing BigQuery table.

Usage:
    python load_cc_statement.py --file /path/to/CCStatement-Aug2026.csv

Requires:
    pip install google-cloud-storage google-cloud-bigquery
    Auth: gcloud auth application-default login
          (or GOOGLE_APPLICATION_CREDENTIALS env var pointing to a service account key)
"""

import argparse
import logging
import os
import sys

from google.cloud import bigquery
from google.cloud import storage

# ---- Config -----------------------------------------------------------
PROJECT_ID = "cc-statement-observability"
GCS_BUCKET = "raw_cc_statements"                
GCS_PREFIX = ""                

BQ_DATASET = "cc_obs_raw"
BQ_TABLE = "cc_statements_raw"                  

BQ_SCHEMA = [
    bigquery.SchemaField("transaction_date", "DATE"),
    bigquery.SchemaField("post_date", "DATE"),
    bigquery.SchemaField("type", "STRING"),
    bigquery.SchemaField("details", "STRING"),
    bigquery.SchemaField("amount", "NUMERIC"),
    bigquery.SchemaField("currency", "STRING"),
]
# -------------------------------------------------------------------------

logging.basicConfig(level=logging.INFO, format="%(asctime)s  %(levelname)s  %(message)s")
logger = logging.getLogger(__name__)


def upload_to_gcs(local_path: str, bucket_name: str, prefix: str) -> str:
    """Upload the local CSV to GCS, returns the gs:// URI."""
    filename = os.path.basename(local_path)
    blob_path = f"{prefix}/{filename}" if prefix else filename

    client = storage.Client(project=PROJECT_ID)
    bucket = client.bucket(bucket_name)
    blob = bucket.blob(blob_path)

    if blob.exists():
        logger.warning("File already exists at gs://%s/%s — it will be overwritten.", bucket_name, blob_path)

    logger.info("Uploading %s -> gs://%s/%s", local_path, bucket_name, blob_path)
    blob.upload_from_filename(local_path)

    gcs_uri = f"gs://{bucket_name}/{blob_path}"
    logger.info("Upload complete: %s", gcs_uri)
    return gcs_uri


def load_to_bigquery(gcs_uri: str, dataset: str, table: str) -> None:
    """Load the CSV at gcs_uri into BigQuery, appending to the target table."""
    client = bigquery.Client(project=PROJECT_ID)
    table_ref = f"{PROJECT_ID}.{dataset}.{table}"

    job_config = bigquery.LoadJobConfig(
        source_format=bigquery.SourceFormat.CSV,
        skip_leading_rows=1,          # header row
        schema=BQ_SCHEMA,
        write_disposition=bigquery.WriteDisposition.WRITE_APPEND,
        max_bad_records=0,
        allow_quoted_newlines=True,
    )

    logger.info("Starting load job: %s -> %s (WRITE_APPEND)", gcs_uri, table_ref)
    load_job = client.load_table_from_uri(gcs_uri, table_ref, job_config=job_config)
    load_job.result()  # blocks until the job finishes, raises on failure

    destination = client.get_table(table_ref)
    logger.info(
        "Load complete. Table %s now has %d rows.",
        table_ref,
        destination.num_rows,
    )


def main():
    parser = argparse.ArgumentParser(description="Upload and load a monthly CC statement CSV into BigQuery.")
    parser.add_argument("--file", required=True, help="Path to the local CCStatement-*.csv file")
    args = parser.parse_args()

    if not os.path.isfile(args.file):
        logger.error("File not found: %s", args.file)
        sys.exit(1)

    gcs_uri = upload_to_gcs(args.file, GCS_BUCKET, GCS_PREFIX)
    load_to_bigquery(gcs_uri, BQ_DATASET, BQ_TABLE)


if __name__ == "__main__":
    main()