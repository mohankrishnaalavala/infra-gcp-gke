variable "project_id" {
  description = "The GCP project ID"
  type        = string
}

variable "pool_id" {
  description = "The Workload Identity Pool ID"
  type        = string
  default     = "github-actions"
}

variable "provider_id" {
  description = "The Workload Identity Provider ID"
  type        = string
  default     = "github-oidc"
}

variable "github_owner" {
  description = "The GitHub organization or user name"
  type        = string
}

variable "repos_needing_wif" {
  description = "List of repository names that need Workload Identity Federation"
  type        = list(string)
  default     = ["fraudguard-boa", "infra-gcp-gke"]
}

variable "default_branches" {
  description = "List of default branches that can use WIF"
  type        = list(string)
  default     = ["main", "develop"]
}

variable "issuer_uri" {
  description = "The OIDC issuer URI"
  type        = string
  default     = "https://token.actions.githubusercontent.com"
}
