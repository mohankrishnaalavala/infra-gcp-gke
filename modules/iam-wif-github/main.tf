terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }
}

# Create Workload Identity Pool
resource "google_iam_workload_identity_pool" "github_pool" {
  project                   = var.project_id
  workload_identity_pool_id = var.pool_id
  display_name              = "GitHub Actions Pool"
  description               = "Workload Identity Pool for GitHub Actions"
}

# Create Workload Identity Provider
resource "google_iam_workload_identity_pool_provider" "github_provider" {
  project                            = var.project_id
  workload_identity_pool_id          = google_iam_workload_identity_pool.github_pool.workload_identity_pool_id
  workload_identity_pool_provider_id = var.provider_id
  display_name                       = "GitHub OIDC Provider"
  description                        = "OIDC identity pool provider for GitHub Actions"

  # Configure the provider for GitHub Actions OIDC
  oidc {
    issuer_uri = var.issuer_uri
  }

  # Map GitHub OIDC token claims to Google Cloud attributes
  attribute_mapping = {
    "google.subject"       = "assertion.sub"
    "attribute.actor"      = "assertion.actor"
    "attribute.repository" = "assertion.repository"
    "attribute.ref"        = "assertion.ref"
  }

  # Restrict access to specific repositories and branches
  attribute_condition = join(" || ", flatten([
    for repo in var.repos_needing_wif : [
      for branch in var.default_branches :
      "attribute.repository == \"${var.github_owner}/${repo}\" && attribute.ref == \"refs/heads/${branch}\""
    ]
  ]))
}

# Create Service Account for CI Builder (build and push images)
resource "google_service_account" "ci_builder" {
  project      = var.project_id
  account_id   = "ci-builder"
  display_name = "CI Builder Service Account"
  description  = "Service account for building and pushing container images"
}

# Create Service Account for CI Deployer (deploy to GKE)
resource "google_service_account" "ci_deployer" {
  project      = var.project_id
  account_id   = "ci-deployer"
  display_name = "CI Deployer Service Account"
  description  = "Service account for deploying applications to GKE"
}

# Grant roles to CI Builder SA
resource "google_project_iam_member" "ci_builder_artifact_registry" {
  project = var.project_id
  role    = "roles/artifactregistry.writer"
  member  = "serviceAccount:${google_service_account.ci_builder.email}"
}

resource "google_project_iam_member" "ci_builder_logging" {
  project = var.project_id
  role    = "roles/logging.logWriter"
  member  = "serviceAccount:${google_service_account.ci_builder.email}"
}

# Grant roles to CI Deployer SA
resource "google_project_iam_member" "ci_deployer_container_admin" {
  project = var.project_id
  role    = "roles/container.admin"
  member  = "serviceAccount:${google_service_account.ci_deployer.email}"
}

resource "google_project_iam_member" "ci_deployer_logging" {
  project = var.project_id
  role    = "roles/logging.logWriter"
  member  = "serviceAccount:${google_service_account.ci_deployer.email}"
}

# Allow GitHub Actions to impersonate CI Builder SA
resource "google_service_account_iam_binding" "ci_builder_workload_identity" {
  service_account_id = google_service_account.ci_builder.name
  role               = "roles/iam.workloadIdentityUser"

  members = [
    for repo in var.repos_needing_wif :
    "principalSet://iam.googleapis.com/${google_iam_workload_identity_pool.github_pool.name}/attribute.repository/${var.github_owner}/${repo}"
  ]
}

# Allow GitHub Actions to impersonate CI Deployer SA
resource "google_service_account_iam_binding" "ci_deployer_workload_identity" {
  service_account_id = google_service_account.ci_deployer.name
  role               = "roles/iam.workloadIdentityUser"

  members = [
    for repo in var.repos_needing_wif :
    "principalSet://iam.googleapis.com/${google_iam_workload_identity_pool.github_pool.name}/attribute.repository/${var.github_owner}/${repo}"
  ]
}
