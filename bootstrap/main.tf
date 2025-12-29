# 1. Кластер
module "kind_cluster" {
  source = "github.com/den-vasyliev/tf-kind-cluster"
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
  config_path       = "${path.module}/kind-cluster-config"
  target_path       = "clusters/my-cluster"
  github_token      = var.github_token
}