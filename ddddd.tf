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

