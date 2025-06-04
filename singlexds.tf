# ================================
# Provider Configuration
# ================================
provider "google" {
  project = var.project_id
  region  = var.region
}

# ===========================
# Secret Manager for Auth
# ===========================

data "google_secret_manager_secret_version" "xmatters_auth_username" {
  secret  = "xMatters_Auth_User"
  project = var.project_id
}

data "google_secret_manager_secret_version" "xmatters_auth_password" {
  secret  = "xMatters_Auth_Passwd"
  project = var.project_id
}

# ============================================
# Notification Channels (xMatters & Email)
# ============================================

resource "google_monitoring_notification_channel" "xmatters_webhook" {
  display_name = "xMatters Webhook"
  type         = "webhook_basicauth"
  project      = var.project_id

  labels = {
    url      = var.xmatters_webhook_url
    username = data.google_secret_manager_secret_version.xmatters_auth_username.secret_data
  }

  sensitive_labels {
    password = data.google_secret_manager_secret_version.xmatters_auth_password.secret_data
  }
}

resource "google_monitoring_notification_channel" "email" {
  display_name = "Email Notification For GCP TF"
  type         = "email"
  project      = var.project_id

  labels = {
    email_address = var.notification_email
  }
}

# ===============================
# Log-based Metric: Flink Warning Logs
# ===============================
resource "google_logging_metric" "flink_warning_logs_testing" {
  name        = "flink_warning_logs_testing"
  description = "Tracks Flink warning logs"
  project     = var.project_id

  filter = <<EOT
resource.type = "k8s_container"
resource.labels.namespace_name = "ecosystem-flink-dev"
resource.labels.container_name = "flink-kubernetes-operator"
textPayload =~ "Warning.+(RESTOREFAILED|JobExecutionException|FAILED|Restarting)"
EOT

  metric_descriptor {
    metric_kind = "DELTA"
    value_type  = "INT64"
    unit        = "1"
  }
}

# ===============================
# Alert Policy: Flink Warning Logs
# ===============================
resource "google_monitoring_alert_policy" "flink_warning_alert_policy_testing" {
  display_name = "Flink-Warning-Alerts-Testing"
  combiner     = "OR"
  enabled      = true
  project      = var.project_id

  notification_channels = [
    google_monitoring_notification_channel.xmatters_webhook.id,
    google_monitoring_notification_channel.email.id
  ]

  conditions {
    display_name = "Flink Warning Logs Condition"

    condition_threshold {
      filter = format(
        "resource.type = \"k8s_container\" AND metric.type = \"logging.googleapis.com/user/%s\"",
        google_logging_metric.flink_warning_logs_testing.name
      )

      comparison      = "COMPARISON_GT"
      threshold_value = 0
      duration        = "0s"

      aggregations {
        alignment_period     = "600s"
        per_series_aligner   = "ALIGN_DELTA"
        cross_series_reducer = "REDUCE_SUM"
      }

      trigger {
        count = 1
      }
    }
  }

  alert_strategy {
    auto_close = "86400s"
  }

  documentation {
    content = templatefile("${path.module}/alert_docs/flink_warning_logs_doc.tpl", {
      project_id = var.project_id
    })
    mime_type = "text/markdown"
  }

  user_labels = {}
}

# ===============================
# Log-based Metric: XDS Error Logs
# ===============================
resource "google_logging_metric" "xds_error_logs_alerts" {
  name        = "xds_error_logs_alerts"
  description = "Tracks XDS-related errors and warnings"
  project     = var.project_id

  filter = <<EOT
resource.type="k8s_container" 
AND (severity="ERROR" OR severity="INFO") 
AND (
  textPayload:"RD10001" OR
  textPayload:"RD10014" OR
  textPayload:"RD10015" OR
  textPayload:"RD10016" OR
  textPayload:"RD10024" OR
  textPayload:"RD10034" OR
  textPayload:"RD10035" OR
  textPayload:"RD10044" OR
  textPayload:"RD10094" OR
  textPayload:"RD10099"
)
EOT

  metric_descriptor {
    metric_kind = "DELTA"
    value_type  = "INT64"
    unit        = "1"
  }
}

# ===============================
# Alert Policy: XDS Error Logs
# ===============================
resource "google_monitoring_alert_policy" "xds_error_logs_alert_policy" {
  display_name = "XDS Error Logs Alerts"
  combiner     = "OR"
  enabled      = true
  project      = var.project_id

  notification_channels = [
    google_monitoring_notification_channel.xmatters_webhook.id,
    google_monitoring_notification_channel.email.id
  ]

  conditions {
    display_name = "XDS Error Logs Condition"

    condition_threshold {
      filter = format(
        "resource.type = \"k8s_container\" AND metric.type = \"logging.googleapis.com/user/%s\"",
        google_logging_metric.xds_error_logs_alerts.name
      )

      comparison      = "COMPARISON_GT"
      threshold_value = 0
      duration        = "0s"

      aggregations {
        alignment_period     = "600s"
        per_series_aligner   = "ALIGN_DELTA"
        cross_series_reducer = "REDUCE_SUM"
      }

      trigger {
        count = 1
      }
    }
  }

  alert_strategy {
    auto_close = "604800s"
  }

  documentation {
    content = templatefile("${path.module}/alert_docs/xds_error_logs_doc.tpl", {
      project_id = var.project_id
    })
    mime_type = "text/markdown"
  }

  user_labels = {}
}
