terraform {
  required_version = ">= 1.9.0"
  required_providers {
    flux = {
      source  = "fluxcd/flux"
      version = ">= 1.5"
    }
    github = {
      source  = "integrations/github"
      version = ">= 6.1"
    }
    kind = {
      source  = "tehcyx/kind"
      version = ">= 0.8"
    }
  }
}

provider "flux" {}

provider "github" {
  token = var.github_token
  owner = var.github_org
}

provider "kind" {}

provider "kubernetes" {
  host                   = module.kind_cluster.endpoint
  client_certificate     = module.kind_cluster.client_certificate
  client_key             = module.kind_cluster.client_key
  cluster_ca_certificate = module.kind_cluster.cluster_ca_certificate
}