documentation {
  content = <<EOT
{
  "severity": "WARNING",
  "text": "${var.project_id} VM High CPU Utilization Alert.",
  "project_id": "${var.project_id}",
  "instance_id": "${resource.label.instance_id}",
  "zone": "${resource.label.zone}",
  "cpu_state": "${metric.label.cpu_state}",
  "cpu_utilization": "${value}",
  "threshold": "${threshold_value}",
  "@key": "6b89d199-64cd-4ec4-ab7d-7514c92283be",
  "@version": "alertapi-0.1",
  "@type": "ALERT"
}
EOT
  mime_type = "text/markdown"
}



"text": "${var.project_id} VM High CPU Utilization Alert. ${summary} ${policy.display_name} ${condition.display_name} ${resource.label.instance_id} ${resource.label.instance_name} ${resource.label.zone} ${resource.type} ${metric.type} ${value} ${threshold_value} ${start_time}",



"text": "${var.project_id} VM High CPU Utilization Alert. Summary: ${summary}, Policy: ${policy.display_name}, Condition: ${condition.display_name}, Instance ID: ${resource.label.instance_id}, Instance Name: ${resource.label.instance_name}, Zone: ${resource.label.zone}, Resource Type: ${resource.type}, Metric Type: ${metric.type}, CPU Utilization: ${value}, Threshold: ${threshold_value}, Start Time: ${start_time}",

"text": "${var.project_id} VM High CPU Utilization Alert. Summary: $${summary}, Policy: $${policy.display_name}, Condition: $${condition.display_name}, Instance ID: $${resource.label.instance_id}, Instance Name: $${resource.label.instance_name}, Zone: $${resource.label.zone}, Resource Type: $${resource.type}, Metric Type: $${metric.type}, CPU Utilization: $${value}, Threshold: $${threshold_value}, Start Time: $${start_time}"






{
  "severity": "WARNING",
  "text": "🚨 **High CPU Utilization Alert Triggered**\n\n- **Instance Name**: $${resource.labels.instance_name}\n- **Instance ID**: $${resource.labels.instance_id}\n- **Zone**: $${resource.labels.zone}\n- **Project ID**: $${resource.labels.project_id}\n- **Resource Type**: $${resource.type}\n- **Metric Type**: $${metric.type}\n- **Condition Name**: $${condition.name}\n- **Metric Display Name**: $${metric.display_name}\n- **Threshold Set**: $${threshold_value}\n- **Actual CPU Usage**: $${value}\n- **Start Time**: $${start_time}\n\n⚠️ Please investigate the affected VM immediately.",
  "object": "VM CPU Utilization",
  "@key": "6b89d199-64cd-4ec4-ab7d-7514c92283be",
  "@version": "alertapi-0.1",
  "@type": "ALERT"
}




{
  "severity": "WARNING",
  "text": "🚨 **High CPU Utilization Alert Triggered**\n\n- **Instance Name**: ${metric.labels.instance_name}\n- **Instance ID**: ${resource.labels.instance_id}\n- **Zone**: ${resource.labels.zone}\n- **Project ID**: ${resource.labels.project_id}\n- **Metric Type**: ${metric.type}\n- **Condition Name**: ${condition.name}\n- **Metric Display Name**: ${metric.display_name}\n\n⚠️ Please investigate the affected VM immediately.",
  "object": "VM CPU Utilization",
  "@key": "6b89d199-64cd-4ec4-ab7d-7514c92283be",
  "@version": "alertapi-0.1",
  "@type": "ALERT"
}




flink_error_logs_doc.tpl
{
  "severity": "WARNING",
  "text": "🚨 **Flink Job Error Alert Triggered**\n\n- **Flink Job Name**: $${labels.job_name}\n- **Flink Pod Name**: $${resource.labels.pod_name}\n- **Namespace**: $${resource.labels.namespace_name}\n- **Cluster Name**: $${resource.labels.cluster_name}\n- **Project ID**: $${resource.labels.project_id}\n- **Resource Type**: $${resource.type}\n- **Metric Type**: $${metric.type}\n- **Condition Name**: $${condition.name}\n- **Metric Display Name**: $${metric.display_name}\n- **Threshold Set**: $${threshold_value}\n- **Triggered Value**: $${value}\n- **Start Time**: $${start_time}\n\n⚠️ Please investigate the failing Flink job and associated resources.",
  "object": "Flink Job Error",
  "@key": "flink-job-alert-uuid",
  "@version": "alertapi-0.1",
  "@type": "ALERT"
}


xds_error_logs_doc.tpl
{
  "severity": "WARNING",
  "text": "🚨 **XDS Error Detected**\n\n- **XDS Pod Name**: $${resource.labels.pod_name}\n- **Namespace**: $${resource.labels.namespace_name}\n- **Cluster Name**: $${resource.labels.cluster_name}\n- **Project ID**: $${resource.labels.project_id}\n- **Resource Type**: $${resource.type}\n- **Metric Type**: $${metric.type}\n- **Condition Name**: $${condition.name}\n- **Metric Display Name**: $${metric.display_name}\n- **Threshold Set**: $${threshold_value}\n- **Triggered Value**: $${value}\n- **Start Time**: $${start_time}\n\n⚠️ Please investigate this XDS-related issue immediately.",
  "object": "XDS Error Logs",
  "@key": "xds-alert-uuid",
  "@version": "alertapi-0.1",
  "@type": "ALERT"
}


vm_cpu_utilization_doc.tpl
{
  "severity": "WARNING",
  "text": "🚨 **High CPU Utilization Alert Triggered**\n\n- **Instance Name**: $${resource.labels.instance_name}\n- **Instance ID**: $${resource.labels.instance_id}\n- **Zone**: $${resource.labels.zone}\n- **Project ID**: $${resource.labels.project_id}\n- **Resource Type**: $${resource.type}\n- **Metric Type**: $${metric.type}\n- **Condition Name**: $${condition.name}\n- **Metric Display Name**: $${metric.display_name}\n- **Threshold Set**: $${threshold_value}\n- **Actual CPU Usage**: $${value}\n- **Start Time**: $${start_time}\n\n⚠️ Please investigate the affected VM immediately.",
  "object": "VM CPU Utilization",
  "@key": "cpu-util-alert-uuid",
  "@version": "alertapi-0.1",
  "@type": "ALERT"
}




sql_memory_utilization_doc.tpl
{
  "severity": "WARNING",
  "text": "🚨 **Cloud SQL High Memory Utilization Alert Triggered**\n\n- **Instance ID**: $${resource.labels.database_id}\n- **Region**: $${resource.labels.region}\n- **Project ID**: $${resource.labels.project_id}\n- **Resource Type**: $${resource.type}\n- **Metric Type**: $${metric.type}\n- **Condition Name**: $${condition.name}\n- **Metric Display Name**: $${metric.display_name}\n- **Threshold Set**: $${threshold_value}\n- **Memory Usage (%)**: $${value}\n- **Start Time**: $${start_time}\n\n⚠️ Please investigate the Cloud SQL instance memory usage immediately.",
  "object": "Cloud SQL Memory Utilization",
  "@key": "cloudsql-mem-alert-uuid",
  "@version": "alertapi-0.1",
  "@type": "ALERT"
}


sql_cpu_utilization_doc.tpl
{
  "severity": "WARNING",
  "text": "🚨 **Cloud SQL High CPU Utilization Alert Triggered**\n\n- **Instance ID**: $${resource.labels.database_id}\n- **Region**: $${resource.labels.region}\n- **Project ID**: $${resource.labels.project_id}\n- **Resource Type**: $${resource.type}\n- **Metric Type**: $${metric.type}\n- **Condition Name**: $${condition.name}\n- **Metric Display Name**: $${metric.display_name}\n- **Threshold Set**: $${threshold_value}\n- **CPU Usage (%)**: $${value}\n- **Start Time**: $${start_time}\n\n⚠️ Please investigate the Cloud SQL instance CPU usage immediately.",
  "object": "Cloud SQL CPU Utilization",
  "@key": "cloudsql-cpu-alert-uuid",
  "@version": "alertapi-0.1",
  "@type": "ALERT"
}


documentation {
  content = templatefile("${path.module}/alert_docs/sql_memory_utilization_doc.tpl", {
    project_id = var.project_id
  })
  mime_type = "text/markdown"
}

vm_high_cpu_utilization_doc.tpl
{
  "severity": "WARNING",
  "text": "🚨 **VM High CPU Utilization Alert Triggered**\n\n- **Instance Name**: $${resource.labels.instance_id}\n- **Zone**: $${resource.labels.zone}\n- **Project ID**: $${resource.labels.project_id}\n- **Resource Type**: $${resource.type}\n- **Metric Type**: $${metric.type}\n- **Condition Name**: $${condition.name}\n- **Metric Display Name**: $${metric.display_name}\n- **Threshold Set**: $${threshold_value}\n- **CPU Usage (%)**: $${value}\n- **Start Time**: $${start_time}\n\n⚠️ Please investigate the high CPU usage on the virtual machine immediately.",
  "object": "VM CPU Utilization",
  "@key": "vm-cpu-alert-uuid",
  "@version": "alertapi-0.1",
  "@type": "ALERT"
}




{
  "severity": "WARNING",
  "text": "**Kubernetes Error Log Alert Triggered**\n\n- **Cluster Name**: $${resource.labels.cluster_name}\n- **Namespace**: $${resource.labels.namespace_name}\n- **Pod Name**: $${resource.labels.pod_name}\n- **Container Name**: $${resource.labels.container_name}\n- **Project ID**: $${resource.labels.project_id}\n- **Resource Type**: $${resource.type}\n- **Metric Type**: $${metric.type}\n- **Condition Name**: $${condition.name}\n- **Metric Display Name**: $${metric.display_name}\n\n Please investigate the affected Kubernetes workload.",
  "object": "Kubernetes Error Logs",
  "@key": "6b89d199-64cd-4ec4-ab7d-7514c92283be",
  "@version": "alertapi-0.1",
  "@type": "ALERT"
}

