# Outputs

output "metric_name" {
  value = google_logging_metric.log_based_metrics.name
}

output "notification_channels" {
  value = [
    google_monitoring_notification_channel.xmatters_webhook.name,
    google_monitoring_notification_channel.email.name
  ]
}
