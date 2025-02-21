# xmatters-code-20022025last
xmatters-code-20022025last


resource "google_monitoring_alert_policy" "log_metric_alert_policy" {
  display_name = "K8s Error Log Alert Policy"
  combiner     = "OR"

  conditions {
    display_name = "Condition: Kubernetes Container - logging/user/k8s_error_log_metric"

    condition_threshold {
      filter = <<EOT
resource.type="k8s_container" AND
metric.type="logging.googleapis.com/user/${google_logging_metric.log_based_metrics.name}"
EOT
      comparison      = "COMPARISON_GT"
      threshold_value = 15
      duration        = "900s" # 15 Minutes

      aggregations {
        alignment_period   = "900s"
        per_series_aligner = "ALIGN_RATE"
      }
    }
  }

  notification_channels = [
    google_monitoring_notification_channel.xmatters_webhook.id,
    google_monitoring_notification_channel.email.id
  ]

  documentation {
    content = <<EOT
{
  "@key": "6b89d199-64cd-4ec4-ab7d-7514c92283be",
  "@version": "alertapi-0.1",
  "@type": "ALERT",
  "object": "Testobject",
  "severity": "CRITICAL",
  "text": "xMatters ERROR Test"
}
EOT
    mime_type = "text/markdown"
  }

  alert_strategy {
    auto_close = "604800s" # 7 days
  }
  severity = "ERROR"
}
