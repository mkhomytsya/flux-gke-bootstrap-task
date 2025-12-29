# GCP Variables
variable "project_id" {
  description = "GCP project ID"
  type        = string
}

variable "region" {
  description = "GCP region for the GKE cluster"
  type        = string
  default     = "us-central1-c"
}

variable "gke_num_nodes" {
  description = "Number of nodes in the GKE cluster"
  type        = number
  default     = 2
}

# GitHub Variables
variable "github_org" {
  description = "GitHub organization or user"
  type        = string
}

variable "github_repository" {
  description = "GitHub repository name for Flux"
  type        = string
}

variable "github_token" {
  description = "GitHub personal access token"
  type        = string
  sensitive   = true
}

# Flux Variables
variable "install_gateway_api" {
  description = "Install Gateway API CRDs"
  type        = bool
  default     = false
}
