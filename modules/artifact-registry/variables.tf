variable "project_id" {
  description = "The GCP project ID"
  type        = string
}

variable "location" {
  description = "The location for the Artifact Registry repository"
  type        = string
  default     = "us"
}

variable "repository_id" {
  description = "The ID of the Artifact Registry repository"
  type        = string
  default     = "fraudguard"
}

variable "description" {
  description = "The description of the repository"
  type        = string
  default     = "FraudGuard Docker images repository"
}

variable "format" {
  description = "The format of the repository"
  type        = string
  default     = "DOCKER"
  
  validation {
    condition     = contains(["DOCKER", "MAVEN", "NPM", "PYTHON", "APT", "YUM"], var.format)
    error_message = "Repository format must be one of: DOCKER, MAVEN, NPM, PYTHON, APT, YUM."
  }
}
