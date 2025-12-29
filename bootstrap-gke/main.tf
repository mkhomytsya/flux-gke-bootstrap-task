# GKE Cluster Module
module "gke_cluster" {
  source         = "github.com/mkhomytsya/tf-google-gke-cluster"
  GOOGLE_REGION  = var.region
  GOOGLE_PROJECT = var.project_id
  GKE_NUM_NODES  = var.gke_num_nodes
}

# Get cluster credentials
data "google_client_config" "default" {}

data "google_container_cluster" "primary" {
  name       = module.gke_cluster.cluster_name
  location   = var.region
  depends_on = [module.gke_cluster]
}

# Generate TLS keys for Flux
module "tls_keys" {
  source = "github.com/den-vasyliev/tf-hashicorp-tls-keys"
}

# Create GitHub repository and add deploy key
module "github_repository" {
  source                   = "github.com/den-vasyliev/tf-github-repository"
  github_owner             = var.github_org
  github_token             = var.github_token
  repository_name          = var.github_repository
  public_key_openssh       = module.tls_keys.public_key_openssh
  public_key_openssh_title = "flux-ssh-key-gke"
}

# Bootstrap Flux CD
module "flux_bootstrap" {
  source            = "github.com/den-vasyliev/tf-fluxcd-flux-bootstrap"
  github_repository = "${var.github_org}/${var.github_repository}"
  private_key       = module.tls_keys.private_key_pem
  config_host       = "https://${data.google_container_cluster.primary.endpoint}"
  config_token      = data.google_client_config.default.access_token
  config_ca         = base64decode(data.google_container_cluster.primary.master_auth[0].cluster_ca_certificate)
  target_path       = "clusters/${var.cluster_name}"
  github_token      = var.github_token
  depends_on        = [google_container_cluster.primary]
}

# Install Gateway API CRDs (optional)
resource "helm_release" "gateway_api" {
  count            = var.install_gateway_api ? 1 : 0
  name             = "gateway-api"
  namespace        = "gateway-system"
  repository       = "oci://docker.io/envoyproxy"
  chart            = "gateway-helm"
  version          = "v1.3.2"
  create_namespace = true
  depends_on       = [module.flux_bootstrap]
}
