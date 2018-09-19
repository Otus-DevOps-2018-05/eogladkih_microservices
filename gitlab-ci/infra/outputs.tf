output "external_ip_addresses" {
    value= ["${google_compute_instance.gitlab.*.network_interface.0.access_config.0.assigned_nat_ip}"]
}
