output "cluster_name" {
  description = "The name of the GKE cluster"
  value       = google_container_cluster.primary.name
}

output "location" {
  description = "The location (region) of the GKE cluster"
  value       = google_container_cluster.primary.location
}

output "endpoint" {
  description = "The cluster endpoint"
  value       = google_container_cluster.primary.endpoint
  sensitive   = true
}

output "workload_pool" {
  description = "The Workload Identity pool for the cluster"
  value       = google_container_cluster.primary.workload_identity_config[0].workload_pool
}

output "cluster_ca_certificate" {
  description = "The cluster CA certificate"
  value       = google_container_cluster.primary.master_auth[0].cluster_ca_certificate
  sensitive   = true
}

output "cluster_id" {
  description = "The cluster ID"
  value       = google_container_cluster.primary.id
}
