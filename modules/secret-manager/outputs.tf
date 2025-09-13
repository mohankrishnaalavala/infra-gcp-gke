output "secret_names" {
  description = "List of created secret names"
  value       = [for secret in google_secret_manager_secret.secrets : secret.secret_id]
}

output "secret_ids" {
  description = "Map of secret names to their full resource IDs"
  value       = { for name, secret in google_secret_manager_secret.secrets : name => secret.id }
}

output "secret_manager_urls" {
  description = "Map of secret names to their Secret Manager URLs"
  value = {
    for name, secret in google_secret_manager_secret.secrets :
    name => "projects/${var.project_id}/secrets/${secret.secret_id}"
  }
}

# Instructions for adding secret versions
output "add_secret_instructions" {
  description = "Instructions for adding secret versions"
  value = <<-EOT
    To add secret versions, use one of the following methods:
    
    1. Using gcloud CLI:
       gcloud secrets versions add gemini-api-key --data-file=- <<< "your-api-key-here"
       gcloud secrets versions add fraudguard-config --data-file=config.json
    
    2. Using Google Cloud Console:
       Navigate to Secret Manager and add versions manually
    
    3. Using Terraform (separate configuration):
       Create google_secret_manager_secret_version resources in your environment-specific configs
  EOT
}
