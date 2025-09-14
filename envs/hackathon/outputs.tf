output "cluster_name" {
  description = "The name of the GKE cluster"
  value       = module.gke_cluster.cluster_name
}

output "cluster_location" {
  description = "The location of the GKE cluster"
  value       = module.gke_cluster.location
}

output "cluster_endpoint" {
  description = "The cluster endpoint"
  value       = module.gke_cluster.endpoint
  sensitive   = true
}

output "workload_pool" {
  description = "The Workload Identity pool for the cluster"
  value       = module.gke_cluster.workload_pool
}

output "ar_repo_url" {
  description = "The Artifact Registry repository URL"
  value       = module.artifact_registry.repo_url
}

output "ci_builder_sa_email" {
  description = "The email of the CI Builder service account"
  value       = module.github_wif.ci_builder_sa_email
}

output "ci_deployer_sa_email" {
  description = "The email of the CI Deployer service account"
  value       = module.github_wif.ci_deployer_sa_email
}

output "github_actions_audience" {
  description = "The audience value for GitHub Actions OIDC authentication"
  value       = module.github_wif.github_actions_audience
}

output "secret_names" {
  description = "List of created secret names"
  value       = module.secret_manager.secret_names
}

output "budget_created" {
  description = "Whether a budget was created"
  value       = module.budgets.budget_created
}

output "budget_amount" {
  description = "The budget amount"
  value       = module.budgets.budget_amount
}

# Post-deployment instructions
output "next_steps" {
  description = "Next steps after infrastructure deployment"
  value       = <<-EOT
    Infrastructure deployment complete! Next steps:

    1. Get cluster credentials:
       gcloud container clusters get-credentials ${module.gke_cluster.cluster_name} --region ${module.gke_cluster.location} --project ${var.project_id}

    2. Create cluster admin binding (optional):
       kubectl create clusterrolebinding bootstrap-admin --clusterrole=cluster-admin --user="$(gcloud config get-value account)"

    3. Add secret versions:
       gcloud secrets versions add gemini-api-key --data-file=- <<< "your-gemini-api-key"
       gcloud secrets versions add fraudguard-config --data-file=config.json

    4. Configure GitHub Actions with these values:
       - WIF_PROVIDER: ${module.github_wif.github_actions_audience}
       - WIF_SERVICE_ACCOUNT_BUILDER: ${module.github_wif.ci_builder_sa_email}
       - WIF_SERVICE_ACCOUNT_DEPLOYER: ${module.github_wif.ci_deployer_sa_email}
       - ARTIFACT_REGISTRY_URL: ${module.artifact_registry.repo_url}
       - GKE_CLUSTER: ${module.gke_cluster.cluster_name}
       - GKE_LOCATION: ${module.gke_cluster.location}
       - PROJECT_ID: ${var.project_id}

    5. Deploy FraudGuard applications:
       cd ../../../fraudguard-boa
       make deploy-all NAMESPACE=fraudguard
  EOT
}

# Budget setup instructions
output "budget_instructions" {
  description = "Budget setup instructions"
  value       = module.budgets.billing_account_required != null ? module.budgets.billing_account_required : "Budget created successfully"
}
