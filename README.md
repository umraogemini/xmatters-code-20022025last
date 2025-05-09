VM Alerting and Memory Utilization Monitoring – Stand-Up Summary
The Terraform code provisions GCP monitoring infrastructure, including log-based metrics, alerting policies, and notification channels (xMatters & email). It securely fetches credentials from Secret Manager and is deployed through a Jenkins pipeline with environment-specific configurations.

📌 Note: This entire monitoring setup is implemented for the Dev environment only at this stage.

🔔 Alert Policies Implemented:
Log-Based Metrics Alert Policy

Monitors the Kube_Error_Logs custom metric from the kube-system namespace.

Triggers alerts when error logs are detected.

VM High Memory & Kubernetes Utilization Alert Policy

GCE VM memory thresholds: >80% and >90%.

Kubernetes node thresholds:

Memory allocatable utilization >50%.

CPU allocatable utilization >50%.

Cloud SQL Memory Utilization Alert Policy

Targets Cloud SQL instances in europe-west2.

Alerts when memory utilization >70% (excluding SIT).

Cloud SQL CPU Utilization Alert Policy

Monitors CPU utilization >70% for Cloud SQL in europe-west2.

SIT environment is excluded from this monitoring.

⚙️ Deployment & Operations Workflow
Terraform provisions all monitoring resources on GCP.

Log-based and GCP-native metrics are continuously evaluated.

Alert policies automatically trigger when metric thresholds are breached.

Notifications are sent via:

xMatters Webhook (with credentials from Secret Manager).

Email notification channel.

Deployments are automated using a Jenkins pipeline with secure and modular configuration.
