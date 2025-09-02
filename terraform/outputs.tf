output "cluster_name" {
  description = "The name of the GKE cluster."
  value       = google_container_cluster.feedback_cluster.name
}

output "cluster_endpoint" {
  description = "The endpoint IP address of the GKE cluster's control plane."
  value       = google_container_cluster.feedback_cluster.endpoint
}

output "cloudbuild_service_account_email" {
  description = "The email of the service account created for Cloud Build GKE deployments."
  value       = google_service_account.cloudbuild_gke_deployer_sa.email
}
