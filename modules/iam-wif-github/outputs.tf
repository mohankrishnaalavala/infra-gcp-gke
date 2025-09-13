output "pool_name" {
  description = "The name of the Workload Identity Pool"
  value       = google_iam_workload_identity_pool.github_pool.name
}

output "provider_name" {
  description = "The name of the Workload Identity Provider"
  value       = google_iam_workload_identity_pool_provider.github_provider.name
}

output "ci_builder_sa_email" {
  description = "The email of the CI Builder service account"
  value       = google_service_account.ci_builder.email
}

output "ci_deployer_sa_email" {
  description = "The email of the CI Deployer service account"
  value       = google_service_account.ci_deployer.email
}

output "workload_identity_pool_id" {
  description = "The ID of the Workload Identity Pool"
  value       = google_iam_workload_identity_pool.github_pool.workload_identity_pool_id
}

output "workload_identity_provider_id" {
  description = "The ID of the Workload Identity Provider"
  value       = google_iam_workload_identity_pool_provider.github_provider.workload_identity_pool_provider_id
}

# Example audience for GitHub Actions OIDC token
output "github_actions_audience" {
  description = "The audience value to use in GitHub Actions for OIDC authentication"
  value       = "//iam.googleapis.com/${google_iam_workload_identity_pool.github_pool.name}/providers/${google_iam_workload_identity_pool_provider.github_provider.workload_identity_pool_provider_id}"
}
