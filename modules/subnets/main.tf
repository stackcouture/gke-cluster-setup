resource "google_compute_subnetwork" "private_subnets" {
  name          = var.subnetwork_name
  ip_cidr_range = var.subnetwork_ip_cidr_range

  region  = var.region_name
  network = var.network_id

  secondary_ip_range {
    range_name    = "pods-range"
    ip_cidr_range = "10.20.0.0/16"
  }

  secondary_ip_range {
    range_name    = "services-range"
    ip_cidr_range = "10.30.0.0/20"
  }

  private_ip_google_access = true
}
