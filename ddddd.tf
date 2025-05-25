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
