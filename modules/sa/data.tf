data "google_artifact_registry_repository" "repo" {
  project       = var.project_id
  location      = var.region_name
  repository_id = "vote-docker-repo"
}