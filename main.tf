# Provider Configuration
provider "google" {
  project = var.project_id
  region  = var.region
}

# Log-based Metric for K8s container errors
resource "google_logging_metric" "Log_Based_Metrics_DEV" {
  name        = "k8s_error_log_metric"
  description = "Track critical error logs for Kubernetes containers"

  filter = <<EOT
    resource.type="k8s_container" AND severity >= "ERROR"
  EOT

  metric_descriptor {
    metric_kind = "DELTA"
    value_type  = "INT64"
    unit        = "1"
  }
}

# xMatters Webhook Notification Channel
resource "google_monitoring_notification_channel" "xmatters_webhook" {
  display_name = "xMatters Webhook_Token TF"
  type         = "webhook_tokenauth"

  labels = {
    url = var.xmatters_webhook_url
  }
}

# Email Notification Channel
resource "google_monitoring_notification_channel" "email" {
  display_name = "Email Notification For GCP TF"
  type         = "email"

  labels = {
    email_address = var.notification_email
  }
}

# Alert Policy for Log-Based Metrics
resource "google_monitoring_alert_policy" "log_metric_alert_policy" {
  display_name = "K8s Error Log Alert Policy"
  combiner     = "OR"

  conditions {
    display_name = "Condition: Kubernetes Container - logging/user/k8s_error_log_metric"

    condition_threshold {
      filter          = "metric.type=\"logging.googleapis.com/user/${google_logging_metric.log_based_metrics.name}\""
      comparison      = "COMPARISON_GT"
      threshold_value = 15
      duration        = "900s" # 15 minutes

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
    mime_type = "text/plain"
  }


###########################################################################################################################################
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
#
  alert_strategy {
    auto_close = "604800s" # 7 days
  }
  severity = "ERROR"
}
##############################################################################################################################


# Provider Configuration
provider "google" {
  project = var.project_id
  region  = var.region
}

# Log-based Metric for K8s container errors
resource "google_logging_metric" "log_based_metrics" {
  name        = "k8s_error_log_metric"
  description = "Track critical error logs for Kubernetes containers"

  filter = <<EOT
resource.type="k8s_container" AND severity >= "ERROR"
EOT

  metric_descriptor {
    metric_kind = "DELTA"
    value_type  = "INT64"
    unit        = "1"
  }
}

# Email Notification Channel
resource "google_monitoring_notification_channel" "email" {
  display_name = "Email Notification For GCP TF"
  type         = "email"

  labels = {
    email_address = var.notification_email
  }
}

# Fetch xMatters Auth Password from Secret Manager
data "google_secret_manager_secret_version" "xmatters_auth" {
  secret = "xmatters_auth_passwd"
}

# xMatters Webhook Notification Channel (Basic Auth)
resource "google_monitoring_notification_channel" "xmatters_webhook" {
  display_name = "xMatters Webhook"
  type         = "webhook_basicauth"

  labels = {
    url      = var.xmatters_webhook_url
    username = "BC000010001"
  }

  sensitive_labels {
    password = data.google_secret_manager_secret_version.xmatters_auth.secret_data
  }
}

# Alert Policy for Log-Based Metrics
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
      duration        = "900s" # 15 minutes

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
