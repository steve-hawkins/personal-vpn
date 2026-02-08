provider "google" {
  alias = "billing"
  user_project_override = true
}

resource "google_monitoring_notification_channel" "email" {
  display_name = "Email Notification Channel"
  type         = "email"
  labels = {
    email_address = var.notification_email
  }
  project = var.gcp_project_id
}

resource "google_monitoring_alert_policy" "network_outbound" {
  project = var.gcp_project_id
  display_name = "Alert for High Network Outbound Traffic"
  combiner     = "OR"
  notification_channels = [google_monitoring_notification_channel.email.name]

  conditions {
    display_name = "VM instance network outbound traffic > 0.9 GB"
    condition_threshold {
      filter     = "metric.type=\"compute.googleapis.com/instance/network/sent_bytes_count\" resource.type=\"gce_instance\""
      duration   = "0s"
      comparison = "COMPARISON_GT"
      threshold_value = "966367641.6" # 0.9 GB in bytes

      aggregations {
        alignment_period = "2592000s" # 30 days
        per_series_aligner = "ALIGN_SUM"
        cross_series_reducer = "REDUCE_SUM"
        group_by_fields = []
        }
        trigger {
        count = 1
        }
    }
  }
  
    documentation {
    content = "This alert fires when the total outbound network traffic from the VPN server exceeds 90% of the 1GB monthly free tier limit."
    mime_type = "text/markdown"
  }
}

resource "google_billing_budget" "budget" {
  provider = google.billing
  billing_account = var.gcp_billing_account_id
  display_name    = "Monthly Budget for Personal VPN"

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
    threshold_percent = 0.5
  }

  threshold_rules {
    threshold_percent = 0.9
  }

  threshold_rules {
    threshold_percent = 1.0
  }

  all_updates_rule {
    monitoring_notification_channels = [google_monitoring_notification_channel.email.name]
    disable_default_iam_recipients   = true
  }
}