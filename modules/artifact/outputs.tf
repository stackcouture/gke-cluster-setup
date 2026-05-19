# output "repository_url" {
#   value = "${var.region_name}-docker.pkg.dev/${var.project_id}/${var.repository_name}"
# }

output "repository_name" {
  value = google_artifact_registry_repository.docker_repo.name
}

output "repository_url" {
  value = "${var.region_name}-docker.pkg.dev/${var.project_id}/${google_artifact_registry_repository.docker_repo.name}"
}