output "vpn_server_ip" {
  description = "The public IP address of the VPN server."
  value       = google_compute_address.vpn_static_ip.address
}
