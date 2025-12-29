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
    local = {
      source  = "hashicorp/local"
      version = ">= 2.5"
    }
    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.12"
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
  host                   = kind_cluster.this.endpoint
  client_certificate     = kind_cluster.this.client_certificate
  client_key             = kind_cluster.this.client_key
  cluster_ca_certificate = kind_cluster.this.cluster_ca_certificate
}

provider "helm" {
  kubernetes = {
    host                   = kind_cluster.this.endpoint
    client_certificate     = kind_cluster.this.client_certificate
    client_key             = kind_cluster.this.client_key
    cluster_ca_certificate = kind_cluster.this.cluster_ca_certificate
  }
}
