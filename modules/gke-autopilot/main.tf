terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }
}

resource "google_container_cluster" "primary" {
  name     = var.cluster_name
  location = var.region
  project  = var.project_id

  # Enable Autopilot
  enable_autopilot = true

  # Network configuration
  network    = var.network
  subnetwork = var.subnetwork

  # Workload Identity configuration
  workload_identity_config {
    workload_pool = "${var.project_id}.svc.id.goog"
  }

  # Minimal configuration for Autopilot

  # Release channel for automatic updates
  release_channel {
    channel = "REGULAR"
  }

  # Deletion protection
  deletion_protection = var.deletion_protection
}
