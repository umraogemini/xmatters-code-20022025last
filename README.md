{
  "severity": "WARNING",
  "text": "🚨 **High CPU Utilization Alert Triggered**\n\n- **Instance Name**: ${metric.labels.instance_name}\n- **Instance ID**: ${resource.labels.instance_id}\n- **Zone**: ${resource.labels.zone}\n- **Project ID**: ${resource.labels.project_id}\n- **Metric Type**: ${metric.type}\n- **Condition Name**: ${condition.name}\n- **Metric Display Name**: ${metric.display_name}\n\n⚠️ Please investigate the affected VM immediately.",
  "object": "VM CPU Utilization",
  "@key": "6b89d199-64cd-4ec4-ab7d-7514c92283be",
  "@version": "alertapi-0.1",
  "@type": "ALERT"
}




documentation {
  content   = templatefile("${path.module}/alert_docs/kube_error_logs_doc.tpl", {})
  mime_type = "text/markdown"
}
