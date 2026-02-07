# This file requires the billing account to be configured in the provider.
# As this is a sensitive information, we will not add it to the provider block.
# Instead, the user should configure the provider with the billing account on their own.
# Instructions on how to do that will be provided in the final output.

data "google_billing_account" "account" {
  billing_account = var.gcp_billing_account_id
}

resource "google_billing_budget" "budget" {
  billing_account = data.google_billing_account.account.id
  display_name    = "Personal VPN Budget"

  budget_filter {
    projects = ["projects/${var.gcp_project_id}"]
  }

  amount {
    specified_amount {
      currency_code = "USD"
      units         = "1"
    }
  }

  threshold_rules {
    threshold_percent = 0.9
  }

  all_updates_rule {
    pubsub_topic = google_pubsub_topic.billing_alerts.id
    schema_version = "1.0"
  }
}

resource "google_pubsub_topic" "billing_alerts" {
  name = "billing-alerts"
}


resource "google_monitoring_notification_channel" "email" {
  display_name = "Email"
  type         = "email"
  labels = {
    email_address = var.notification_email
  }
}

resource "google_monitoring_alert_policy" "cpu_utilization" {
  display_name = "High CPU Utilization"
  combiner     = "OR"
  notification_channels = [
    google_monitoring_notification_channel.email.id,
  ]

  conditions {
    display_name = "CPU utilization for the VPN instance is over 90% for 15 minutes"
    condition_threshold {
      filter          = "metric.type=\"compute.googleapis.com/instance/cpu/utilization\" AND resource.type=\"gce_instance\" AND metadata.user_labels.app=\"personal-vpn-server\""
      duration        = "900s"
      comparison      = "COMPARISON_GT"
      threshold_value = 0.9
      trigger {
        percent = 1
      }
    }
  }
}
