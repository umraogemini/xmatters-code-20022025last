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
data "google_secret_manager_secret_version" "xmatters_auth" {
  secret  = "xmatters_auth_passwd"
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
    username = "BC000010001"
  }

  sensitive_labels {
    password = data.google_secret_manager_secret_version.xmatters_auth.secret_data
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
# Alert Policy: Flink Warnings
# ===============================
resource "google_monitoring_alert_policy" "flink_warning_alert_policy" {
  display_name = "Flink-Warning-Alerts"
  combiner     = "OR"
  enabled      = true
  project      = var.project_id

  notification_channels = [
    google_monitoring_notification_channel.xmatters_webhook.id,
    google_monitoring_notification_channel.email.id
  ]

  conditions {
    display_name = "Flink Warning Logs"

    condition_matched_log {
      filter = <<EOT
resource.type = "k8s_container"
resource.labels.namespace_name = "ecosystem-flink-dev"
resource.labels.container_name = "flink-kubernetes-operator"
textPayload =~ "Warning.+(RESTOREFAILED|JobExecutionException|FAILED|Restarting)"
EOT
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
