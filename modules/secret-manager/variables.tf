variable "project_id" {
  description = "The GCP project ID"
  type        = string
}

variable "secret_names" {
  description = "List of secret names to create"
  type        = list(string)
  default     = ["gemini-api-key", "fraudguard-config"]
}

variable "replication_policy" {
  description = "The replication policy for secrets"
  type        = string
  default     = "automatic"

  validation {
    condition     = contains(["automatic", "user-managed"], var.replication_policy)
    error_message = "Replication policy must be either 'automatic' or 'user-managed'."
  }
}

variable "labels" {
  description = "Labels to apply to all secrets"
  type        = map(string)
  default = {
    project     = "fraudguard"
    environment = "hackathon"
    managed-by  = "terraform"
  }
}
