# ========================
# Provider Configuration
# ========================
provider "google" {
  project = var.project_id
  region  = var.region
}

# ================================
# Log-Based Metric Configuration
# ================================
resource "google_logging_metric" "Log_Based_Metrics_DEV" {
  name        = "Kube_Error_Logs"
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

# ============================
# Secret Manager Configuration
# ============================
data "google_secret_manager_secret_version" "xmatters_auth" {
  secret  = "xmatters_auth_passwd"
  project = var.project_id
}

# ===========================================
# Notification Channels (xMatters and Email)
# ===========================================
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

# =============================
# Log-Based Alert Policy
# =============================
resource "google_monitoring_alert_policy" "Log_Based_Metrics_DEV" {
  display_name = "Kube_Error_Logs"
  combiner     = "OR"
  enabled      = true
  project      = var.project_id

  notification_channels = [
    google_monitoring_notification_channel.xmatters_webhook.name,
    google_monitoring_notification_channel.email.name
  ]

  conditions {
    display_name = "Kube_Error_Logs"

    condition_threshold {
      filter = <<EOT
resource.type="k8s_container" AND metric.type="logging.googleapis.com/user/${google_logging_metric.Log_Based_Metrics_DEV.name}"
EOT
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
}

# =============================
# VM High Memory Alert Policy
# =============================
resource "google_monitoring_alert_policy" "vm_high_memory_alert" {
  display_name = "VM High Memory Alert"
  combiner     = "OR"
  enabled      = true
  project      = var.project_id

  notification_channels = [
    "projects/${var.project_id}/notificationChannels/11076007616266814838"
  ]

  alert_strategy {
    auto_close           = "86400s"
    notification_prompts = ["OPENED"]
  }

  documentation {
    content = <<EOT
{
  "severity": "WARNING",
  "text": "VM Instance - Memory utilization (OS reported) exceeded 80%\\nmetric: agent.googleapis.com/memory/percent_used\\nproject.id: ${var.project_id}\\nzone: \\"\\ninstance.id: \\"",
  "object": "VMMemory",
  "@key": "6b89d199-64cd-4ec4-ab7d-7514c92283be",
  "@version": "alertapi-0.1",
  "@type": "ALERT"
}
EOT
    mime_type = "text/markdown"
  }

  user_labels = {}
}

# =============================
# VM Memory Utilization Condition
# =============================
resource "google_monitoring_alert_policy_condition" "vm_memory_utilization" {
  display_name = "VM Instance - Memory utilization (OS reported) exceeded 80%"
  alert_policy = google_monitoring_alert_policy.vm_high_memory_alert.name
  project      = var.project_id

  condition_threshold {
    filter = <<EOT
resource.type = "gce_instance" AND metric.type = "agent.googleapis.com/memory/percent_used" AND metric.labels.state = "used" AND NOT metadata.system_labels.name = monitoring.regex.full_match("nongo.*")
EOT
    duration         = "300s"
    comparison       = "COMPARISON_GT"
    threshold_value  = 80

    aggregations {
      alignment_period   = "300s"
      per_series_aligner = "ALIGN_MEAN"
    }

    trigger {
      count = 1
    }
  }
}

# =============================
# Node Memory Utilization Alert Policy
# =============================
resource "google_monitoring_alert_policy" "node_memory_exceed_50" {
  display_name = "Nodes memory exceed 50%"
  combiner     = "OR"
  enabled      = true
  project      = var.project_id

  notification_channels = [
    "projects/${var.project_id}/notificationChannels/11076007616266814838"
  ]

  conditions {
    display_name = "Kubernetes Node - Memory allocatable utilization exceeded 50%"

    condition_threshold {
      filter          = "resource.type = \"k8s_node\" AND metric.type = \"kubernetes.io/node/memory/allocatable_utilization\""
      duration        = "0s"
      comparison      = "COMPARISON_GT"
      threshold_value = 0.5

      aggregations {
        alignment_period   = "300s"
        per_series_aligner = "ALIGN_MAX"
      }

      trigger {
        count = 1
      }
    }
  }

  documentation {
    content = <<EOT
{
  "severity": "WARNING",
  "text": "Kubernetes Node - Memory allocatable utilization exceeded 50%\\nmetric: kubernetes.io/node/memory/allocatable_utilization\\nproject_id: ${var.project_id}\\nlocation: \\\"\\ncluster name: \\\"\\nnode_name: \\\"",
  "object": "NodeMemory",
  "@key": "6b89d199-64cd-4ec4-ab7d-7514c92283be",
  "@version": "alertapi-0.1",
  "@type": "ALERT"
}
EOT
    mime_type = "text/markdown"
  }

  alert_strategy {
    auto_close = "86400s"
  }

  user_labels = {}
}
