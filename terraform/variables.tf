variable "project_id" {
  description = "The GCP project ID where resources will be deployed."
  type        = string
}

variable "region" {
  description = "The GCP region for the GKE cluster and other resources."
  type        = string
  default     = "us-central1" # You can change this to your preferred region (e.g., europe-west1, us-east1)
}

variable "cluster_name" {
  description = "The name of the GKE cluster."
  type        = string
  default     = "feedback-cluster" # A descriptive name for your cluster
}
