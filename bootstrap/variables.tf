variable "github_org" {
  description = "GitHub organization or user"
  type        = string
}

variable "github_repository" {
  description = "GitHub repository name"
  type        = string
}

variable "github_token" {
  description = "GitHub token"
  sensitive   = true
  type        = string
}