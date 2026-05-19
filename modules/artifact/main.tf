# resource "google_project_service" "artifact_registry" {
#   project            = var.project_id
#   service            = "artifactregistry.googleapis.com"
#   disable_on_destroy = false
# }

resource "google_project_service" "artifact_registry" {
  for_each = toset([
    "container.googleapis.com",
    "compute.googleapis.com",
    "iam.googleapis.com",
    "artifactregistry.googleapis.com",
    "monitoring.googleapis.com",
    "logging.googleapis.com"
  ])

  project = var.project_id
  service = each.key

  disable_on_destroy = false
}


resource "google_artifact_registry_repository" "docker_repo" {
  location      = var.region_name
  repository_id = var.repository_name
  description   = var.repository_description
  format        = var.repository_format
  depends_on = [
    google_project_service.artifact_registry
  ]
}