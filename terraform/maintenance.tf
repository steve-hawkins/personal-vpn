resource "google_os_config_patch_deployment" "weekly_updates" {
  patch_deployment_id = "weekly-apt-upgrades"
  instance_filter {
    group_labels {
      labels = {
        app = "personal-vpn-server"
      }
    }
  }

  patch_config {
    apt {
      type = "DIST"
    }
  }

  recurring_schedule {
    time_zone {
      id = "UTC"
    }
    
    time_of_day {
      hours   = 2
      minutes = 0
      seconds = 0
      nanos   = 0
    }

    weekly {
      day_of_week = "SUNDAY"
    }
  }
}
