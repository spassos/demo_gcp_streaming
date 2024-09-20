provider "google" {
  project = var.project_id
  region  = var.region
}

resource "google_pubsub_topic" "demo_topic" {
  name = "demo-topic"
}

resource "google_pubsub_subscription" "demo_subscription" {
  name  = "demo-subscription"
  topic = google_pubsub_topic.demo_topic.id
}

resource "google_bigquery_dataset" "demo_dataset" {
  dataset_id = "streaming_demo_dataset"
  location   = var.region
}

resource "google_bigquery_table" "demo_table" {
  dataset_id = google_bigquery_dataset.demo_dataset.dataset_id
  table_id   = "streaming_demo_table"
  schema     = file("${path.module}/schema.json")
  deletion_protection=false
}

resource "google_dataflow_job" "streaming_pipeline" {
  name              = "dataflow-streaming-job"
  template_gcs_path = "gs://dataflow-templates-us-central1/latest/PubSub_to_BigQuery"
  parameters = {
    inputTopic  = "projects/${var.project_id}/topics/${google_pubsub_topic.demo_topic.name}"
    outputTableSpec = "${var.project_id}:${google_bigquery_dataset.demo_dataset.dataset_id}.${google_bigquery_table.demo_table.table_id}"
  }
  temp_gcs_location = "gs://${google_storage_bucket.dataflow_bucket.name}/temp/"
  on_delete         = "cancel"
  network           = "dev-vpc"
  subnetwork        = "https://www.googleapis.com/compute/v1/projects/${var.project_id}/regions/${var.region}/subnetworks/dev-subnet-01"
  region            = var.region
}

resource "google_storage_bucket" "dataflow_bucket" {
  name     = "${var.project_id}-dataflow-bucket"
  location = var.region
}