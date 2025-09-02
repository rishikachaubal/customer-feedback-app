# Configure the Google Cloud provider
provider "google" {
  project = var.project_id
  region  = var.region
}

# GKE Cluster Resource
resource "google_container_cluster" "feedback_cluster" {
  name     = var.cluster_name
  location = var.region # Use 'location' for regional clusters

  # Workload Identity (Bonus Points)
  # The presence of this block enables Workload Identity.
  workload_identity_config {}

  # Release channel for automatic updates (recommended for managed clusters)
  release_channel {
    channel = "REGULAR" # Provides a balance of stability and new features
  }

  # Define the default node pool
  # This replaces initial_node_count and min_node_count at the cluster level
  node_pool {
    name               = "default-node-pool" # Default name for the initial node pool
    initial_node_count = 2                   # Initial number of nodes
    node_config {
      machine_type = "e2-medium"
      disk_size_gb = 50 # A good balance of cost and performance
      oauth_scopes = [
        "https://www.googleapis.com/auth/cloud-platform", # Broad scope, allows nodes to interact with GCP services
      ]
    }
    # Autoscaling configuration (optional, but good for min_node_count)
    autoscaling {
      min_node_count = 2 # Ensure at least 2 nodes are always running
      max_node_count = 5 # Example: allow scaling up to 5 nodes
    }
  }

  # Optional: Enable VPC-native cluster for better networking and Workload Identity
  # networking_mode = "VPC_NATIVE"
  # ip_allocation_policy {
  #   cluster_ipv4_cidr_block       = "/19"
  #   services_ipv4_cidr_block      = "/22"
  #   cluster_secondary_range_name  = "pods"
  #   services_secondary_range_name = "services"
  # }

  # Optional: Enable private cluster for enhanced security (nodes have no public IPs)
  # private_cluster_config {
  #   enable_private_nodes    = true
  #   enable_private_endpoint = false # Set to true if you want internal access only
  #   master_ipv4_cidr_block  = "172.16.0.0/28" # CIDR for master authorized networks
  # }
}

# Service Account for Cloud Build to interact with GKE and GCR
# This SA will be granted permissions to deploy to GKE and push images to GCR.
resource "google_service_account" "cloudbuild_gke_deployer_sa" {
  account_id   = "cloudbuild-gke-deployer" # A unique ID for the service account
  display_name = "Service Account for Cloud Build GKE Deployment"
  project      = var.project_id
}

# Grant necessary IAM roles to the Cloud Build Service Account
# 1. Role to deploy applications to GKE
resource "google_project_iam_member" "cloudbuild_gke_developer_binding" {
  project = var.project_id
  role    = "roles/container.developer" # Allows managing deployments, services, etc.
  member  = "serviceAccount:${google_service_account.cloudbuild_gke_deployer_sa.email}"
}

# 2. Role to push Docker images to Google Container Registry (GCR)
# GCR uses Cloud Storage buckets, so storage.admin is a common role for this.
resource "google_project_iam_member" "cloudbuild_gcr_admin_binding" {
  project = var.project_id
  role    = "roles/storage.admin" # Allows full control over Cloud Storage buckets (where GCR images are stored)
  member  = "serviceAccount:${google_service_account.cloudbuild_gke_deployer_sa.email}"
}

# 3. Role to allow Cloud Build to impersonate the GKE node service account (for Workload Identity)
# This is important if your GKE nodes need to access other GCP services (e.g., pull images from GCR).
# It allows the Cloud Build SA to act as the default compute service account used by GKE nodes.
resource "google_project_iam_member" "cloudbuild_gke_sa_user_binding" {
  project = var.project_id
  role    = "roles/iam.serviceAccountUser"
  member  = "serviceAccount:${google_service_account.cloudbuild_gke_deployer_sa.email}"
  # The service account that the Cloud Build SA is allowed to impersonate.
  # This is typically the default Compute Engine service account for the project.
  # You can find its email in IAM & Admin -> Service Accounts. It usually looks like:
  # <PROJECT_NUMBER>-compute@developer.gserviceaccount.com
  # For now, this binding is a good general practice.
}
