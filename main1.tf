# Provider Configuration
provider "google" {
  project = var.project_id
  region  = var.region
}

# ==============================
# Log-Based Metric Configuration
# ==============================

resource "google_logging_metric" "demoemailtest" {
  name        = "Demoemailtest"
  description = "Demoemailtest"
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

# ==============================
# Secret Manager Configuration
# ==============================

# Fetch xMatters Auth Password from Secret Manager
data "google_secret_manager_secret_version" "xmatters_auth" {
  secret  = "xmatters_auth_passwd"
  project = var.project_id
}

# ==============================
# Notification Channels
# ==============================

# xMatters Webhook Notification Channel (Basic Auth)
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

# Email Notification Channel
resource "google_monitoring_notification_channel" "email" {
  display_name = "Email Notification For GCP TF"
  type         = "email"
  project      = var.project_id

  labels = {
    email_address = var.notification_email
  }
}

# =======================
# Alert Policy Definition
# =======================

resource "google_monitoring_alert_policy" "demo_email_test1" {
  display_name = "Demoeamiltest1"
  combiner     = "OR"
  enabled      = true
  project      = var.project_id

  notification_channels = [
    "projects/${var.project_id}/notificationChannels/11076007616266814838"
  ]

  conditions {
    display_name = "Demoemailtest1"

    condition_threshold {
      filter     = "metric.type=\"logging.googleapis.com/user/${google_logging_metric.demoemailtest.name}\""
      duration   = "0s"
      comparison = "COMPARISON_GT"

      aggregations {
        alignment_period     = "60s"
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

    notification_rate_limit {
      period = "60s"
    }
  }

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

  user_labels = {}

  lifecycle {
    ignore_changes = [creation_record, mutation_record]
  }
}
