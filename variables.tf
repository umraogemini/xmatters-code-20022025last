variable "project_id" {
  description = "The GCP project ID"
  type        = string
}

variable "region" {
  description = "The GCP region"
  type        = string
  default     = "europe-west2"
}

variable "xmatters_webhook_url" {
  description = "Webhook URL for xMatters integration"
  type        = string
  default     = "https://hap-api.hsbc.co.uk/api/sendAlert?@aboutSource=GCP"
}

variable "notification_email" {
  description = "Email address for receiving alerts"
  type        = string
  default     = "etfineexpeakdeliveryteamitsupport@noexternalmail.hsbc.com"
}
