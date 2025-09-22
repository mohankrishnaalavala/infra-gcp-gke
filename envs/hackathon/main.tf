terraform {
  required_version = ">= 1.0"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }

  # Remote state storage in GCS
  backend "gcs" {
    bucket = "fraudguard-hackathon-terraform-state"
    prefix = "fraudguard/hackathon"
  }
}

# Configure the Google Cloud Provider
provider "google" {
  project = var.project_id
  region  = var.region
}

# Terraform state bucket
resource "google_storage_bucket" "terraform_state" {
  name          = "fraudguard-hackathon-terraform-state"
  location      = var.region
  force_destroy = false

  versioning {
    enabled = true
  }

  lifecycle_rule {
    condition {
      num_newer_versions = 5
    }
    action {
      type = "Delete"
    }
  }

  public_access_prevention = "enforced"
}

# Enable required APIs
resource "google_project_service" "required_apis" {
  for_each = toset([
    "container.googleapis.com",
    "artifactregistry.googleapis.com",
    "secretmanager.googleapis.com",
    "iam.googleapis.com",
    "iamcredentials.googleapis.com",
    "cloudbilling.googleapis.com",
    "monitoring.googleapis.com",
    "logging.googleapis.com"
  ])

  project = var.project_id
  service = each.value

  disable_on_destroy = false
}

# Create GKE Autopilot cluster
module "gke_cluster" {
  source = "../../modules/gke-autopilot"

  project_id          = var.project_id
  region              = var.region
  cluster_name        = var.cluster_name
  deletion_protection = var.enable_deletion_protection

  depends_on = [google_project_service.required_apis]
}

# Create Artifact Registry repository
module "artifact_registry" {
  source = "../../modules/artifact-registry"

  project_id    = var.project_id
  repository_id = var.ar_repo_id

  depends_on = [google_project_service.required_apis]
}

# Create Workload Identity Federation for GitHub Actions
module "github_wif" {
  source = "../../modules/iam-wif-github"

  project_id        = var.project_id
  github_owner      = var.github_owner
  repos_needing_wif = var.repos_needing_wif
  default_branches  = var.default_branches

  depends_on = [google_project_service.required_apis]
}

# Static IP for ingress
resource "google_compute_global_address" "fraudguard_ip" {
  name = "fraudguard-ip"
}

# Create Secret Manager secrets
module "secret_manager" {
  source = "../../modules/secret-manager"

  project_id = var.project_id

  depends_on = [google_project_service.required_apis]
}

# Create budget (optional) - temporarily disabled for troubleshooting
# module "budgets" {
#   source = "../../modules/budgets"
#
#   project_id          = var.project_id
#   billing_account_id  = var.billing_account_id
#   amount              = var.budget_amount
#   notification_emails = var.budget_notification_emails
#
#   depends_on = [google_project_service.required_apis]
# }
