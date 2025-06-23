{
  "severity": "WARNING",
  "text": "**Ingestion Service Error Log Alert Triggered**\n\n- **Cluster Name**: $${resource.labels.cluster_name}\n- **Namespace**: $${resource.labels.namespace_name}\n- **Pod Name**: $${resource.labels.pod_name}\n- **Project ID**: $${resource.labels.project_id}\n- **Resource Type**: $${resource.type}\n- **Metric Type**: $${metric.type}\n- **Condition Name**: $${condition.name}\n- **Metric Display Name**: $${metric.display_name}\n\nPlease investigate the ingestion service for possible issues.",
  "object": "Ingestion Service Error",
  "@key": "d1f9d77b-9f1b-4d8a-abe4-9093c2bdee23",
  "@version": "alertapi-0.1",
  "@type": "ALERT"
}
