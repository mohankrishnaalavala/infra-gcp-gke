output "repository_id" {
  description = "The ID of the Artifact Registry repository"
  value       = google_artifact_registry_repository.repo.repository_id
}

output "repository_name" {
  description = "The name of the Artifact Registry repository"
  value       = google_artifact_registry_repository.repo.name
}

output "repo_url" {
  description = "The repository URL for pushing/pulling images"
  value       = "${var.location}-docker.pkg.dev/${var.project_id}/${var.repository_id}"
}

output "location" {
  description = "The location of the repository"
  value       = google_artifact_registry_repository.repo.location
}
