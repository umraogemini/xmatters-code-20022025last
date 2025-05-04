# Outputs
output "metric_name" {
  value = google_logging_metric.Log_Based_Metrics_DEV.name
}

output "notification_channels" {
  value = [
    google_monitoring_notification_channel.xmatters_webhook.name,
    google_monitoring_notification_channel.email.name
  ]
}
