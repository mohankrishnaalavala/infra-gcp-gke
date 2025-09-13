variable "project_id" {
  description = "The GCP project ID"
  type        = string
  default     = "fraudguard-hackathon"
}

variable "region" {
  description = "The GCP region for resources"
  type        = string
  default     = "us-central1"
}

variable "cluster_name" {
  description = "The name of the GKE cluster"
  type        = string
  default     = "fraudguard-auto"
}

variable "ar_repo_id" {
  description = "The Artifact Registry repository ID"
  type        = string
  default     = "fraudguard"
}

variable "github_owner" {
  description = "The GitHub organization or user name"
  type        = string
  default     = "mohankrishnaalavala"
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

variable "billing_account_id" {
  description = "The billing account ID for budget creation (optional)"
  type        = string
  default     = ""
}

variable "budget_amount" {
  description = "The budget amount in USD"
  type        = number
  default     = 100
}

variable "budget_notification_emails" {
  description = "List of email addresses for budget notifications"
  type        = list(string)
  default     = []
}

variable "enable_deletion_protection" {
  description = "Whether to enable deletion protection on the GKE cluster"
  type        = bool
  default     = false
}
