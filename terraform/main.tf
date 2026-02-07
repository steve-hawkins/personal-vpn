terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 5.20.0"
    }
  }
}

provider "google" {
  project = var.gcp_project_id
  region  = var.gcp_region
  zone    = var.gcp_zone
}

resource "google_compute_network" "vpn_network" {
  name                    = "personal-vpn-network"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "vpn_subnet" {
  name          = "personal-vpn-subnet"
  ip_cidr_range = "10.0.1.0/24"
  network       = google_compute_network.vpn_network.id
  region        = var.gcp_region
}

resource "google_compute_firewall" "wireguard" {
  name    = "allow-wireguard"
  network = google_compute_network.vpn_network.name
  allow {
    protocol = "udp"
    ports    = ["51820"]
  }
  source_ranges = ["0.0.0.0/0"]
}

resource "google_compute_address" "vpn_static_ip" {
  name   = "personal-vpn-static-ip"
  region = var.gcp_region
}

resource "google_compute_instance_template" "vpn_template" {
  name         = "personal-vpn-template"
  machine_type = var.machine_type
  region       = var.gcp_region

  labels = {
    "app" = "personal-vpn-server"
  }

  disk {
    source_image = "debian-cloud/debian-11"
    auto_delete  = true
    boot         = true
  }

  network_interface {
    network    = google_compute_network.vpn_network.id
    subnetwork = google_compute_subnetwork.vpn_subnet.id
    access_config {
      nat_ip = google_compute_address.vpn_static_ip.address
    }
  }

  scheduling {
    automatic_restart   = true
    on_host_maintenance = "MIGRATE"
  }

  metadata_startup_script = file("${path.module}/../scripts/startup.sh")

  service_account {
    scopes = ["cloud-platform"]
  }
}

resource "google_compute_instance_group_manager" "vpn_igm" {
  name               = "personal-vpn-igm"
  base_instance_name = "personal-vpn-vm"
  zone               = var.gcp_zone
  version {
    instance_template = google_compute_instance_template.vpn_template.id
  }
  target_size = 1

  auto_healing_policies {
    health_check      = google_compute_health_check.autohealing.id
    initial_delay_sec = 300
  }
}

resource "google_compute_health_check" "autohealing" {
  name                = "autohealing-health-check"
  check {
    tcp_health_check {
      port = 22
    }
  }
  timeout_sec         = 5
  check_interval_sec  = 5
  healthy_threshold   = 2
  unhealthy_threshold = 2
}
