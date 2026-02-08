variable "gcp_project_id" {
  description = "The GCP project ID to deploy the VPN server to."
  type        = string
}

variable "gcp_region" {
  description = "The GCP region to deploy the VPN server to."
  type        = string
  default     = "us-central1"

  validation {
    condition     = contains(["us-west1", "us-central1", "us-east1"], var.gcp_region)
    error_message = "The GCP region must be one of the following to be eligible for the GCP Free Tier: us-west1, us-central1 or us-east1."
  }
}

variable "machine_type" {
  description = "The machine type to use for the VPN server."
  type        = string
  default     = "e2-micro"

  validation {
    condition     = var.machine_type == "e2-micro"
    error_message = "The machine type must be e2-micro to be eligible for the GCP Free Tier."
  }
}

variable "notification_email" {
  description = "The email address to send monitoring alerts to."
  type        = string
}

variable "gcp_billing_account_id" {
  description = "The GCP billing account ID to associate with the project for budget monitoring."
  type        = string
}
