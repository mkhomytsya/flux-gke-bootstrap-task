# 1. Кластер
module "kind_cluster" {
  source = "github.com/den-vasyliev/tf-kind-cluster"
}

# Створюємо kubeconfig, використовуючи ПРАВИЛЬНІ назви outputs модуля
resource "local_file" "kubeconfig" {
  content  = <<EOF
apiVersion: v1
clusters:
- cluster:
    certificate-authority-data: ${base64encode(module.kind_cluster.ca)}
    server: ${module.kind_cluster.endpoint}
  name: kind
contexts:
- context:
    cluster: kind
    user: kind
  name: kind
current-context: kind
kind: Config
preferences: {}
users:
- name: kind
  user:
    client-certificate-data: ${base64encode(module.kind_cluster.crt)}
    client-key-data: ${base64encode(module.kind_cluster.client_key)}
EOF
  filename = "${path.module}/kubeconfig"
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