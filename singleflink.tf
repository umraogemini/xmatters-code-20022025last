# ================================
# Provider Configuration
# ================================
provider "google" {
  project = var.project_id
  region  = var.region
}

# ================================
# Secret Manager for Auth
# ================================
data "google_secret_manager_secret_version" "xmatters_auth_username" {
  secret  = "xMatters_Auth_Username"
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
  display_name = "xMatters Webhook Testing one"
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
  display_name = "Email Notification Testing one"
  type         = "email"
  project      = var.project_id

  labels = {
    email_address = var.notification_email
  }
}

# ===============================
# Log-Based Metric: Flink Logs
# ===============================
resource "google_logging_metric" "flink_log_alert_metric" {
  name        = "Flink_Log_Errorstesting"
  description = "Tracks Flink job error logs"
  project     = var.project_id

  filter = <<EOT
resource.type="k8s_container"
AND severity="ERROR"
AND logName:"/logs/flink"
# resource.type="k8s_container"
# AND resource.labels.namespace_name="flink"
# AND severity="ERROR"
EOT

  metric_descriptor {
    metric_kind = "DELTA"
    value_type  = "INT64"
    unit        = "1"
  }
}

# ===============================
# Alert Policy: Flink Log Errors
# ===============================
resource "google_monitoring_alert_policy" "flink_log_alert_policy" {
  display_name = "Flink-errortesting"
  combiner     = "OR"
  enabled      = true
  project      = var.project_id

  notification_channels = [
    google_monitoring_notification_channel.xmatters_webhook.id,
    google_monitoring_notification_channel.email.id
  ]

  conditions {
    display_name = "Flink log"

    condition_threshold {
      filter = format(
        "resource.type = \"k8s_container\" AND metric.type = \"logging.googleapis.com/user/%s\"",
        google_logging_metric.flink_log_alert_metric.name
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
    content = templatefile("${path.module}/alert_docs/flink_error_logs_doc.tpl", {
      project_id = var.project_id
    })
    mime_type = "text/markdown"
  }

  user_labels = {}
}


resource.type = "k8s_container"
resource.labels.cluster_name = "trayplat"
resource.labels.container_name = "flink-kuberneten-operator"
resource.labels.namespace_name =~ "ecosystem-flink-.+"
textPayload =~ "Event\\s+\\.+JOBSTATUSCHANGED.+to FAILED"
textPayload =~ "nill"


resource.type = "k8s_container"
resource.labels.namespace_name = "ecosystem-flink-prod"
resource.labels.container_name = "flink-jobmanager"
textPayload =~ "JobExecutionException|Task.*failed|Restarting.*job"


resource.type = "k8s_container"
resource.labels.namespace_name = "ecosystem-flink-prod"
resource.labels.container_name = "flink-jobmanager"
(textPayload =~ "JobExecutionException" OR textPayload =~ "Task.*failed" OR textPayload =~ "Restarting.*job")



resource.type = "k8s_container"
resource.labels.namespace_name = "ecosystem-flink-prod"
resource.labels.container_name = "flink-jobmanager"
severity = "WARNING"
textPayload =~ "checkpoint|backpressure|retries|retrying|timed out|partitions.*unavailable"




resource.type = "k8s_container"
resource.labels.cluster_name = "trsyplat"
resource.labels.container_name = "flink-kubernetes-operator"
resource.labels.namespace_name =~ "ecosystem-flink-.*"
textPayload =~ "Event\\s+\\|.*JOBSTATUSCHANGED.*to FAILED.*nil"

