# 1. Кластер
resource "kind_cluster" "this" {
  name           = "kind-cluster"
  wait_for_ready = true
}

# Створюємо kubeconfig файл для Flux
resource "local_file" "kubeconfig" {
  content              = kind_cluster.this.kubeconfig
  filename             = "${path.module}/kind-cluster-config"
  file_permission      = "0600"
  directory_permission = "0700"
}

# 2. SSH ключі для Flux
module "tls_keys" {
  source = "github.com/den-vasyliev/tf-hashicorp-tls-keys"
}

# 3. Репозиторій GitHub
module "github_repository" {
  source                   = "github.com/den-vasyliev/tf-github-repository"
  github_owner             = var.github_org
  github_token             = var.github_token
  repository_name          = var.github_repository
  public_key_openssh       = module.tls_keys.public_key_openssh
  public_key_openssh_title = "flux-ssh-key"
}

# 4. Flux Bootstrap
module "flux_bootstrap" {
  source            = "github.com/den-vasyliev/tf-fluxcd-flux-bootstrap"
  github_repository = "${var.github_org}/${var.github_repository}"
  private_key       = module.tls_keys.private_key_pem
  config_path       = local_file.kubeconfig.filename
  target_path       = "clusters/my-cluster"
  github_token      = var.github_token
}

# ==========================================
# Bootstrap Envoy Gateway
# ==========================================
resource "helm_release" "envoy_gateway" {
  depends_on       = [module.flux_bootstrap]
  name             = "eg"
  namespace        = "envoy-gateway-system"
  repository       = "oci://docker.io/envoyproxy"
  chart            = "gateway-helm"
  version          = "v1.3.2"
  create_namespace = true
}