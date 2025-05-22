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

resource "google_logging_metric" "log_based_metrics_dev" {
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

# ================================
# Email Notification
# ================================

resource "google_monitoring_notification_channel" "email" {
  display_name = "Email Notification For GCP TF"
  type         = "email"
  project      = var.project_id

  labels = {
    email_address = var.notification_email
  }
}

# ========================
# Alert Policy
# ========================

resource "google_monitoring_alert_policy" "log_based_metrics_dev" {
  display_name = "Kube_Error_Logs"
  combiner     = "OR"
  enabled      = true
  project      = var.project_id

  notification_channels = [
    "project/${var.project_id}/notifiationChannels/14755094464550284125",
    "project/${var.project_id}/notifiationChannels/3455478624500074369"
  ]

  conditions {
    display_name = "Kube Error Logs Detected"

    condition_threshold {
      filter = <<EOT
resource.type="k8s_container" AND metric.type="logging.googleapis.com/user/${google_logging_metric.log_based_metrics_dev.name}"
EOT
      duration   = "300s"
      comparison = "COMPARISON_GT"

      aggregations {
        alignment_period     = "300s"
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
    content = <<-EOT

{
  "severity": "WARNING",
  "text": "${var.project_id} VM High Memory Utilization Alert on instance ${resource.labels.instance_id} (${metadata.system_labels.name})"
  "project_id": "${var.project_id}",
  "object": "VM or Kubernetes Node",
  "vm_name": "${resource.label.instance_id}",
  "zone": "${resource.label.zone}",
  "@key": "6b89d199-64cd-4ec4-ab7d-7514c92283be",
  "@version": "alertapi-0.1",
  "@type": "Kube_Error_Logs Alert"
}
EOT
    mime_type = "text/markdown"
  }

  user_labels = {}
}

# ===============================
# VM Resource Utilization Alerts
# ===============================

resource "google_monitoring_alert_policy" "vm_resource_utilization_alert" {
  display_name = "VM & Node Resource Utilization"
  combiner     = "OR"
  enabled      = true
  project      = var.project_id

  notification_channels = [
    "project/${var.project_id}/notifiationChannels/14755094464550284125",
    "project/${var.project_id}/notifiationChannels/3455478624500074369"
  ]

# ===============================
# Condation 1 VM Memory >80%
# ===============================

  conditions {
    display_name = "VM Memory Utilization > 80%"

    condition_threshold {
      filter = <<EOT
resource.type = "gce_instance"
AND metric.type = "agent.googleapis.com/memory/percent_used"
AND metric.labels.state = "used"
AND NOT metadata.system_lables.name = monitoring.regex.full_match("nongo.*")
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
  
# ===============================
# Condation 2 Node Memory >50%
# ===============================

   conditions {
    display_name = "K8s Node Memory > 50%"

    condition_threshold {
      filter = "resource.type = \"k8s_node\" AND metric.type = \"kubernetes.io/node/memory/allocatable_utilization\""
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

# ===============================
# Condation 3 Node CPU >50%
# ===============================

  conditions {
    display_name = "K8s Node CPU > 50%"

    condition_threshold {
      filter = "resource.type = \"k8s_node\" AND metric.type = \"kubernetes.io/node/cpu/allocatable_utilization\""
      duration        = "300s"
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
  alert_strategy {
    auto_close = "86400s"
  }

  documentation {
    content = <<EOT

{
  "severity": "WARNING",
  "text": "${var.project_id} VM High Memory Utilization Alert on instance ${resource.labels.instance_id} (${metadata.system_labels.name})"
  "project_id": "${var.project_id}",
  "object": "VM CPU | Node Memory | Node CPU Utilization",
  "vm_name": "${resource.label.instance_id}",
  "zone": "${resource.label.zone}",
  "@key": "6b89d199-64cd-4ec4-ab7d-7514c92283be",
  "@version": "alertapi-0.1",
  "@type": "ALERT"
}
EOT
    mime_type = "text/markdown"
  }
}

# ===============================
# VM High CPU Utilization Alerts
# ===============================

resource "google_monitoring_alert_policy" "vm_high_cpu_utilization" {
  display_name = "VM High CPU Utilization Alert"
  combiner     = "OR"
  enabled      = true
  project      = var.project_id

  notification_channels = [
    "project/${var.project_id}/notifiationChannels/14755094464550284125",
    "project/${var.project_id}/notifiationChannels/3455478624500074369"
  ]

  conditions {
    display_name = "VM CPU Utilization > 80%"

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
  "text": "${var.project_id} VM High CPU Utilization Alert on instance ${resource.labels.instance_id} (${metadata.system_labels.name})"
  "project_id": "${var.project_id}",
  "object": "VM CPU Utilization",
  "instance_id": "${resource.label.instance_id}",
  "zone": "${resource.label.zone}",
  "@key": "6b89d199-64cd-4ec4-ab7d-7514c92283be",
  "@version": "alertapi-0.1",
  "@type": "ALERT"
}
EOT
    mime_type = "text/markdown"
  }

  user_labels = {}
}


# ===============================
# Cloud SQL Memory Utlization Alerts
# ===============================

resource "google_monitoring_alert_policy" "cloud_sql_utilization" {
  display_name = "Cloud SQL Memory Utilization"
  combiner     = "OR"
  enabled      = true
  project      = var.project_id

  notification_channels = [
    "project/${var.project_id}/notifiationChannels/14755094464550284125",
    "project/${var.project_id}/notifiationChannels/3455478624500074369"
  ]

  conditions {
    display_name = "Cloud SQL Database - Memory utilization"

    condition_threshold {
      filter = resource.type =\"cloudsql_database\" AND resource.labels.region = \"europe-west2\" AND metric.type = \"cloudsql.googleapis.com/database/memory/utilization\""
      duration        = "0s"
      comparison      = "COMPARISON_GT"
      threshold_value = 70

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
    content = <<-EOT
{
  "severity": "WARNING",
  "text": "${var.project_id} Cloud SQL memory utilization threshold exceeded on instance ${resource.labels.database_id}"
  "project_id": "${var.project_id}",
  "object": "CloudSQLMemory",
  "instance_id": "${resource.label.database_id}",
  "region": "${resource.label.region}",
  "availability": "Zonal",
  "tier": "${resource.label.tier}",
  "disk_type": "${resource.label.disk_type}",
  "disk_size": "${resource.label.disk_size}",
  "@key": "6b89d199-64cd-4ec4-ab7d-7514c92283be",
  "@version": "alertapi-0.1",
  "@type": "ALERT"
}
EOT
    mime_type = "text/markdown"
  }

  user_labels = {}
}

# ===============================
# Cloud SQL CPU Utilization Alert Policy 
# ===============================

resource "google_monitoring_alert_policy" "cloud_sql_cpu_utilization" {
  display_name = "Cloud SQL CPU Utilization"
  combiner     = "OR"
  enabled      = true
  project      = var.project_id

  notification_channels = [
    "project/${var.project_id}/notifiationChannels/14755094464550284125",
    "project/${var.project_id}/notifiationChannels/3455478624500074369"
  ]

  conditions {
    display_name = "Cloud SQL Database -CPU utilization 80%"

    condition_threshold {
      filter = <EOT
resource.type = "cloudsql_database" 
AND resource.labels.region = "europe-west2" 
AND metric.type = "cloudsql.googleapis.com/database/cpu/utilization"
EOT
      duration        = "0s"
      comparison      = "COMPARISON_GT"
      threshold_value = 70

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
    auto_close = "86400s"
    
  }

  documentation {
    content = <<-EOT
{
  "severity": "WARNING",
  "text": "${var.project_id} Cloud SQL CPU utilization threshold exceeded on instance ${resource.labels.database_id}"
  "project_id": "${var.project_id}",
  "object": "CloudSQL",
  "instance_id": "${resource.label.database_id}",
  "region": "${resource.label.region}",
  "availability": "Zonal",
  "tier": "${resource.label.tier}",
  "disk_type": "${resource.label.disk_type}",
  "disk_size": "${resource.label.disk_size}",
  "@key": "6b89d199-64cd-4ec4-ab7d-7514c92283be",
  "@version": "alertapi-0.1",
  "@type": "ALERT"
}
EOT
    mime_type = "text/markdown"
  }

user_labels ={}
}

# ===============================
# Log-Based Metric: Flink Logs
# ===============================

resource "google_logging_metric" "flink_log_alert_metric" {
  name        = "Flink_Log_Errors"
  description = "Tracks Flink job error logs"
  project     = var.project_id

  filter = <<EOT
resource.type="k8s_container"
AND severity="ERROR"
AND logName:"flink"
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
  display_name = "Flink-error"
  combiner     = "OR"
  enabled      = true
  project      = var.project_id

  notification_channels = [
    "project/${var.project_id}/notifiationChannels/14755094464550284125",
    "project/${var.project_id}/notifiationChannels/3455478624500074369"
  ]

  conditions {
    display_name = "Flink log"

    condition_threshold {
      filter = <<EOT
resource.type = "k8s_container" AND metric.type = "logging.googleapis.com/user/${google_logging_metric.flink_log_alert_metric.name}"
EOT

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
    content = <<EOT
{
  "severity": "CRITICAL",
  "text": "${var.project_id} Flink job alert - Pod: ${resource.labels.pod_name}, Container: ${resource.labels.container_name}"
  "project_id": "${var.project_id}",
  "job": "Flink Job",
  "pod_name": "${resource.label.pod_name}",
  "namespace": "${resource.label.namespace_name}",
  "container_name": "${resource.label.container_name}",
  "@type": "ALERT"
}
EOT
    mime_type = "text/markdown"
  }

  user_labels = {}
}


# ===============================
# XDS Alert Policy
# ===============================

resource "google_logging_metric" "xds_error_logs_alerts" {
  name        = "XDS_Error_Logs_Alerts"
  description = "Tracks XDS-related errors and warnings"
  project     = var.project_id

  filter = <<EOT
resource.type="k8s_container" 
AND severity=("ERROR" OR "INFO") 
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
    metric_kind = "CUMULATIVE"
    value_type  = "INT64"
    unit        = "1"
  }
}

# ================================
# Alert Policy: XDS Error Logs
# ================================

resource "google_monitoring_alert_policy" "xds_error_logs_alerts" {
  display_name = "XDS Error Logs Alerts"
  combiner     = "OR"
  enabled      = true
  project      = var.project_id

  notification_channels = [
    "project/${var.project_id}/notifiationChannels/14755094464550284125",
    "project/${var.project_id}/notifiationChannels/3455478624500074369"
  ]

  conditions {
    display_name = "XDS Error Logs Detected"

    condition_threshold {
      filter = <<EOT
resource.type="k8s_container" AND metric.type="logging.googleapis.com/user/${google_logging_metric.xds_error_logs_alerts.name}"
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
    auto_close = "604800s"  # 7 days
  }

  documentation {
    content = <<EOT
{
  "@key": "6b89d199-64cd-4ec4-ab7d-7514c92283be",
  "@version": "alertapi-0.1",
  "@type": "ALERT",
  "object": "XDS Error Event",
  "severity": "CRITICAL",
  "project_id": "${var.project_id}",
  "pod_name": "${resource.label.pod_name}",
  "container_name": "${resource.label.container_name}",
  "text": "${var.project_id} xMatters XDS ERROR Alert - Pod: ${resource.labels.pod_name}, Container: ${resource.labels.container_name}"
}
EOT
    mime_type = "text/markdown"
  }
}
