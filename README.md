# Flux CD GitOps Bootstrap Project

This project automates the deployment of a Kubernetes cluster (KinD) and bootstraps it with Flux CD using Terraform modules.

## Quick Start

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

For other issues, refer to the Makefile help: `make help`
