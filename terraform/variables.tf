variable "gcp_project_id" {
  description = "The GCP project ID to deploy the VPN server to."
  type        = string
}

variable "gcp_region" {
  description = "The GCP region to deploy the VPN server to."
  type        = string
  default     = "us-central1"
}

variable "gcp_zone" {
  description = "The GCP zone to deploy the VPN server to."
  type        = string
  default     = "us-central1-a"
}

variable "machine_type" {
  description = "The machine type for the VPN server."
  type        = string
  default     = "e2-micro"
}

variable "notification_email" {
  description = "The email address to send monitoring alerts to."
  type        = string
}

variable "gcp_billing_account_id" {
  description = "The GCP billing account ID to associate with the project for budget monitoring."
  type        = string
}
