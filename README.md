# Flux CD GitOps Bootstrap Project

This project automates the deployment of Kubernetes clusters and bootstraps them with Flux CD using Terraform modules.

## Available Configurations

- **KinD (Kubernetes in Docker)** - Local development cluster (in `bootstrap/` directory)
- **GKE (Google Kubernetes Engine)** - Production-ready GKE cluster (in `bootstrap-gke/` directory)

Choose the configuration that fits your needs.

## Quick Start

### For KinD (Local Development)

1. **Install Tools**:
   ```bash
   make bootstrap
   ```
   > **Note:** Ensure your GitHub token has `repo` and `delete_repo` permissions for repository management.

2. **Cleanup**:
   To remove all resources (infrastructure, cluster, Flux, GitHub repo):
   ```bash
   make destroy
   ```
   To clean up temporary files and configs:
   ```bash
   make clean
   ```

### For GKE (Production)

See detailed instructions in [bootstrap-gke/README.md](bootstrap-gke/README.md)

**Quick commands:**

1. **Setup GCP and Deploy**:
   ```bash
   # Check GCP setup
   make -f Makefile.gke gcp-check
   
   # Enable GCP APIs
   make -f Makefile.gke gcp-setup
   
   # Full bootstrap (interactive)
   make -f Makefile.gke bootstrap-gke
   ```

2. **Cleanup**:
   ```bash
   make -f Makefile.gke destroy-gke
   ```

## SSH Key Management

The project generates SSH keys for Flux to authenticate with the GitHub repository.

### Regenerating SSH Keys

If you encounter an error like "key is already in use" when adding the deploy key to GitHub, it means the SSH public key is already used in another repository. To regenerate new SSH keys:

```bash
make regenerate-ssh-keys
make apply
```

This will taint the TLS private key resource, forcing Terraform to generate a new key pair on the next apply.

## Troubleshooting

### Repository Already Exists Error

If you encounter: "Repository creation failed... name already exists on this account"

The GitHub repository from a previous deployment still exists. You have two options:
1. **Use a different repository name:** Run `make clean` and `make bootstrap` with a new GitHub repository name.
2. **Delete the old repository:** Manually delete the old repository from GitHub, then re-run `make apply`.

You can also update the repository name in `bootstrap/terraform.tfvars`:
```bash
# Edit this file and change github_repository to a new name
nano bootstrap/terraform.tfvars
make apply
```
