# ================================
# Provider Configuration
# ================================

provider "google" {
  project = var.project_id
  region  = var.region
}

# ================================
# Log-Based Metric Configuration
# ================================

resource "google_logging_metric" "Log_Testing_DEV" {
  name        = "test_metric_one"
  description = "Counts the number of error logs in kube-system namespace"
  project     = var.project_id

  filter = <<EOT
resource.labels.namespace_name="kube-system" AND severity="ERROR"
EOT

  metric_descriptor {
    metric_kind = "DELTA"
    value_type  = "INT64"
    unit        = "1"
  }
}

# ===========================
# Secret Manager Access
# ===========================

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
    username = "BC000010001"  # Optionally, also from Secret Manager
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
# VM High CPU Utilization Alerts
# ===============================

resource "google_monitoring_alert_policy" "vm_high_cpu_utilization_alert" {
  display_name = "VM High CPU Testing one"
  combiner     = "OR"
  enabled      = true
  project      = var.project_id

  notification_channels = [
    google_monitoring_notification_channel.xmatters_webhook.id,
    google_monitoring_notification_channel.email.id
  ]

  conditions {
    display_name = "VM CPU Utilization Testing one > 80%"

    condition_threshold {
      filter = <<EOT
resource.type ="gce_instance"
AND metric.type ="agent.googleapis.com/cpu/utilization"
EOT
      duration        = "300s"
      comparison      = "COMPARISON_GT"
      threshold_value = 80

      aggregations {
        alignment_period   = "300s"
        per_series_aligner = "ALIGN_MEAN"
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
    content = <<EOT
{
  "severity": "WARNING",
  "text": "${var.project_id} VM High CPU Utilization Alert.",
  "project_id": "${var.project_id}",
  "object": "VM CPU Utilization",
  "@key": "6b89d199-64cd-4ec4-ab7d-7514c92283be",
  "@version": "alertapi-0.1",
  "@type": "ALERT"
}
EOT
    mime_type = "text/markdown"
  }

  user_labels = {}
}

