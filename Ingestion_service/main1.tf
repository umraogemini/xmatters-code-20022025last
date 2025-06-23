resource "google_monitoring_alert_policy" "Ingestion_Log_Based_Metrics_DEV" {
  display_name = "Ingestion_Error_Logs"
  combiner     = "OR"
  enabled      = true
  project      = var.project_id

  notification_channels = [
    google_monitoring_notification_channel.email.id
  ]

  conditions {
    display_name = "Ingestion_Error_Logs"

    condition_threshold {
      filter = <<EOT
resource.type="k8s_container" AND metric.type="logging.googleapis.com/user/${google_logging_metric.ingestion_error_logs_metric.name}"
EOT
      duration   = "900s"
      comparison = "COMPARISON_GT"

      aggregations {
        alignment_period     = "900s"
        cross_series_reducer = "REDUCE_SUM"
        per_series_aligner   = "ALIGN_DELTA"
      }

      trigger {
        count = 1
      }
    }
  }

  alert_strategy {
    auto_close = "604800s" # 7 days
  }

  documentation {
    content = templatefile("${path.module}/alert_docs/ingestion_error_logs_doc.tpl", {
      project_id = var.project_id
    })
    mime_type = "text/markdown"
  }

  user_labels = {}
}
