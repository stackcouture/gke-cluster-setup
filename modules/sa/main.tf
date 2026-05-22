resource "google_service_account" "gke_nodes" {
  account_id   = "gke-node-sa"
  display_name = "GKE Node Service Account"
}

resource "google_project_iam_member" "gke_node_logging" {
  project = var.project_id # data.google_client_config.current.project
  role    = "roles/logging.logWriter"
  member  = "serviceAccount:${google_service_account.gke_nodes.email}"
}

resource "google_project_iam_member" "gke_node_monitoring" {
  project = var.project_id # data.google_client_config.current.project
  role    = "roles/monitoring.metricWriter"
  member  = "serviceAccount:${google_service_account.gke_nodes.email}"
}

resource "google_project_iam_member" "gke_node_monitoring_viewer" {
  project = var.project_id # project = data.google_client_config.current.project
  role    = "roles/monitoring.viewer"
  member  = "serviceAccount:${google_service_account.gke_nodes.email}"
}

resource "google_project_iam_member" "gke_node_service_account_role" {
  project = var.project_id
  role    = "roles/container.nodeServiceAccount"
  member  = "serviceAccount:${google_service_account.gke_nodes.email}"
}

resource "google_project_iam_member" "gke_node_storage_viewer" {
  project = var.project_id
  role    = "roles/storage.objectViewer"
  member  = "serviceAccount:${google_service_account.gke_nodes.email}"
}

resource "google_artifact_registry_repository_iam_member" "repo_reader" {
  project    = var.project_id
  location   = var.region_name
  repository = var.repository_name # google_artifact_registry_repository.docker_repo.name
  role       = "roles/artifactregistry.reader"
  member     = "serviceAccount:${google_service_account.gke_nodes.email}"
}

# Service Account for Secrets 
resource "google_service_account" "eso_gsa" {
  account_id   = "eso-gsa"
  display_name = "External Secrets Operator GSA"
}

resource "google_project_iam_member" "secret_accessor" {
  project = var.project_id
  role    = "roles/secretmanager.secretAccessor"
  member  = "serviceAccount:${google_service_account.eso_gsa.email}"
}

resource "google_service_account_iam_member" "workload_identity" {
  service_account_id = google_service_account.eso_gsa.name
  role               = "roles/iam.workloadIdentityUser"
  member             = "serviceAccount:${var.project_id}.svc.id.goog[external-secrets/external-secrets]"
}

# Service Account for Loki
resource "google_service_account" "loki_gsa" {
  account_id   = "loki-gsa"
  display_name = "Loki GSA"
}

resource "google_project_iam_member" "gke_loki_storage_viewer" {
  project = var.project_id
  role    = "roles/storage.objectAdmin"
  member  = "serviceAccount:${google_service_account.loki_gsa.email}"
}

resource "google_service_account_iam_member" "loki_workload_identity" {
  service_account_id = google_service_account.loki_gsa.name
  role               = "roles/iam.workloadIdentityUser"
  member             = "serviceAccount:${var.project_id}.svc.id.goog[observability/loki]"
}

