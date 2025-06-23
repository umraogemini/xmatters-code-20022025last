resource "google_logging_metric" "ingestion_error_logs_metric" {
  name        = "Ingestion_Error_Logs"
  description = "Counts the number of error logs in the ingestion service"
  project     = var.project_id

  filter = <<EOT
resource.labels.namespace_name="ingestion-namespace" AND severity="ERROR"
EOT

  metric_descriptor {
    metric_kind = "DELTA"
    value_type  = "INT64"
    unit        = "1"
  }
}
