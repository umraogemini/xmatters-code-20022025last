resource "google_logging_metric" "data_watcher_service_logs_alerts" {
  name        = "Data_Watcher_Service_Logs_Alerts"
  description = "Peak Data Watcher service related errors and warnings"
  project     = var.project_id

  filter = <<EOT
resource.type = "k8s_container"
AND (severity="ERROR" OR severity="INFO")
AND (
  textPayload:"DWATCHER11002" OR
  textPayload:"DWATCHER11003" OR
  textPayload:"DWATCHER20002" OR
  textPayload:"DWATCHER20005" OR
  textPayload:"DWATCHER20006" OR
  textPayload:"DWATCHER20007" OR
  textPayload:"DWATCHER20009" OR
  textPayload:"DWATCHER20010" OR
  textPayload:"DWATCHER20011" OR
  textPayload:"DWATCHER20012"
)
EOT

  metric_descriptor {
    metric_kind = "DELTA"
    value_type  = "INT64"
    unit        = "1"
  }
}


resource "google_monitoring_alert_policy" "data_watcher_service_logs_alerts" {
  display_name = "Data Watcher Service Logs Alerts"
  combiner     = "OR"
  enabled      = true
  project      = var.project_id

  notification_channels = [
    # google_monitoring_notification_channel.xmatters_webhook.id,
    google_monitoring_notification_channel.email.id
  ]

  conditions {
    display_name = "Data Watcher Service Logs Alerts"

    condition_threshold {
      filter = format(
        "resource.type = \"k8s_container\" AND metric.type = \"logging.googleapis.com/user/%s\"",
        google_logging_metric.data_watcher_service_logs_alerts.name
      )
      duration    = "0s"
      comparison  = "COMPARISON_GT"

      aggregations {
        alignment_period     = "300s"
        cross_series_reducer = "REDUCE_SUM"
        per_series_aligner   = "ALIGN_DELTA"
      }

      trigger {
        count = 1
      }
    }
  }

  alert_strategy {
    auto_close = "604800s" // 7 days
  }

  documentation {
    content = templatefile("${path.module}/alert_docs/data_watcher_service_logs_doc.tpl", {
      project_id = var.project_id
    })
    mime_type = "text/markdown"
  }

  user_labels = {}
}
