resource "google_container_cluster" "demo_cluster" {

  project  = var.project_id
  name     = "${var.project_id}-gke"
  location = var.location_name

  deletion_protection = var.deletion_protection
  datapath_provider   = "ADVANCED_DATAPATH"

  network    = var.compute_network_name
  subnetwork = var.compute_subnetwork_name

  initial_node_count       = var.initial_node_count       # 2
  remove_default_node_pool = var.remove_default_node_pool # true

  ip_allocation_policy {
    cluster_secondary_range_name  = "pods-range"
    services_secondary_range_name = "services-range"
  }

  release_channel {
    channel = "REGULAR"
  }

  workload_identity_config {
    workload_pool = "${var.project_id}.svc.id.goog"
  }

  private_cluster_config {
    enable_private_nodes    = true
    enable_private_endpoint = false
    master_ipv4_cidr_block  = "172.16.0.0/28"
  }

  enable_shielded_nodes = true

  logging_service    = "logging.googleapis.com/kubernetes"
  monitoring_service = "monitoring.googleapis.com/kubernetes"

  addons_config {
    network_policy_config {
      disabled = false
    }

    gce_persistent_disk_csi_driver_config {
      enabled = true
    }

    http_load_balancing {
      disabled = false
    }

    horizontal_pod_autoscaling {
      disabled = false
    }
  }
}

resource "google_container_node_pool" "system_pool" {
  name     = "system-pool"
  cluster  = google_container_cluster.demo_cluster.name
  location = google_container_cluster.demo_cluster.location

  initial_node_count = 1

  autoscaling {
    min_node_count = 1
    max_node_count = 3
  }

  upgrade_settings {
    max_surge       = 1
    max_unavailable = 0
  }

  lifecycle {
    ignore_changes = [
      initial_node_count
    ]
  }

  management {
    auto_repair  = true
    auto_upgrade = true
  }

  node_config {
    machine_type = "e2-standard-2"
    image_type   = "COS_CONTAINERD"

    disk_type    = "pd-standard"
    disk_size_gb = 30

    service_account = var.sa_node_email

    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]

    labels = {
      env = "dev"
    }

    taint {
      key    = "workload"
      value  = "system"
      effect = "NO_SCHEDULE"
    }

    metadata = {
      disable-legacy-endpoints = "true"
    }

    shielded_instance_config {
      enable_secure_boot          = true
      enable_integrity_monitoring = true
    }

    tags = ["gke-node"]
  }
}

resource "google_container_node_pool" "app_pool" {

  name     = "app-pool"
  cluster  = google_container_cluster.demo_cluster.name
  location = google_container_cluster.demo_cluster.location

  initial_node_count = 1

  autoscaling {
    min_node_count = 1
    max_node_count = 3
  }

  upgrade_settings {
    max_surge       = 1
    max_unavailable = 0
  }

  lifecycle {
    ignore_changes = [
      initial_node_count
    ]
  }

  management {
    auto_repair  = true
    auto_upgrade = true
  }

  node_config {
    machine_type = "e2-standard-2"
    image_type   = "UBUNTU_CONTAINERD"

    disk_type    = "pd-standard"
    disk_size_gb = 20

    service_account = var.sa_node_email

    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]

    metadata = {
      disable-legacy-endpoints = "true"
    }

    labels = {
      workload = "applications"
      env      = "dev"
    }

    shielded_instance_config {
      enable_secure_boot          = true
      enable_integrity_monitoring = true
    }

    tags = ["general-app-pool"]
  }
}