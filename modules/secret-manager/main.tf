terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }
}

# Create placeholder secrets (no versions)
resource "google_secret_manager_secret" "secrets" {
  for_each  = toset(var.secret_names)
  project   = var.project_id
  secret_id = each.value

  labels = var.labels

  replication {
    dynamic "auto" {
      for_each = var.replication_policy == "automatic" ? [1] : []
      content {}
    }

    dynamic "user_managed" {
      for_each = var.replication_policy == "user-managed" ? [1] : []
      content {
        replicas {
          location = "us-central1"
        }
        replicas {
          location = "us-east1"
        }
      }
    }
  }

  # TODO: Add secret versions manually or via separate process
  # This module only creates the secret containers, not the actual secret values
  # Use: gcloud secrets versions add <secret-name> --data-file=<file>
  # Or: echo -n "secret-value" | gcloud secrets versions add <secret-name> --data-file=-
}

# Grant access to the GKE service account to read secrets
# This will be configured when the cluster is created
data "google_project" "current" {
  project_id = var.project_id
}

# Create IAM policy for Secret Manager access
resource "google_secret_manager_secret_iam_member" "secret_accessor" {
  for_each  = toset(var.secret_names)
  project   = var.project_id
  secret_id = google_secret_manager_secret.secrets[each.value].secret_id
  role      = "roles/secretmanager.secretAccessor"

  # Grant access to the default GKE service account
  # In production, you should use Workload Identity with specific service accounts
  member = "serviceAccount:${data.google_project.current.number}-compute@developer.gserviceaccount.com"
}
