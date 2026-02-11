# Quick Reference

Fast lookup guide for common DevOps Images commands, volume mounts, and usage patterns.

---

## Essential Commands

### Pull Images

```bash
# All-devops (multi-cloud)
docker pull ghcr.io/jinalshah/devops/images/all-devops:latest

# AWS-only
docker pull ghcr.io/jinalshah/devops/images/aws-devops:latest

# GCP-only
docker pull ghcr.io/jinalshah/devops/images/gcp-devops:latest
```

### Run Interactively

```bash
# Basic interactive shell
docker run -it --rm ghcr.io/jinalshah/devops/images/all-devops:latest

# With project mounted
docker run -it --rm \
  -v $PWD:/workspace \
  -w /workspace \
  ghcr.io/jinalshah/devops/images/all-devops:latest

# Full workstation setup
docker run -it --rm \
  -v $PWD:/workspace \
  -v ~/.aws:/root/.aws \
  -v ~/.config/gcloud:/root/.config/gcloud \
  -v ~/.ssh:/root/.ssh \
  -w /workspace \
  ghcr.io/jinalshah/devops/images/all-devops:latest
```

### Run Single Commands

```bash
# Terraform
docker run --rm -v $PWD:/workspace -w /workspace \
  ghcr.io/jinalshah/devops/images/all-devops:latest \
  terraform plan

# Ansible
docker run --rm -v $PWD:/workspace -w /workspace \
  ghcr.io/jinalshah/devops/images/all-devops:latest \
  ansible-playbook site.yml

# kubectl
docker run --rm -v ~/.kube:/root/.kube \
  ghcr.io/jinalshah/devops/images/all-devops:latest \
  kubectl get pods
```

---

## Volume Mounts Cheat Sheet

| Mount | Purpose | When Needed |
|-------|---------|-------------|
| `-v $PWD:/workspace` | Project files | Always (for accessing code) |
| `-v ~/.aws:/root/.aws` | AWS credentials | AWS operations |
| `-v ~/.config/gcloud:/root/.config/gcloud` | GCP credentials | GCP operations |
| `-v ~/.ssh:/root/.ssh` | SSH keys | Git operations, SSH access |
| `-v ~/.kube:/root/.kube` | Kubernetes config | kubectl operations |
| `-v ~/.claude:/root/.claude` | Claude AI credentials | Claude CLI |
| `-v ~/.codex:/root/.codex` | Codex credentials | Codex CLI |
| `-v ~/.terraform.d:/root/.terraform.d` | Terraform plugins cache | Speed up Terraform |

---

## Common Workflows

### Terraform Deployment

```bash
# Plan
docker run --rm \
  -v $PWD:/workspace \
  -v ~/.aws:/root/.aws \
  -w /workspace \
  ghcr.io/jinalshah/devops/images/all-devops:latest \
  terraform plan

# Apply
docker run --rm \
  -v $PWD:/workspace \
  -v ~/.aws:/root/.aws \
  -w /workspace \
  ghcr.io/jinalshah/devops/images/all-devops:latest \
  terraform apply -auto-approve
```

### Security Scanning

```bash
# Scan Terraform configs
docker run --rm -v $PWD:/workspace \
  ghcr.io/jinalshah/devops/images/all-devops:latest \
  trivy config /workspace/terraform

# Lint Terraform
docker run --rm -v $PWD:/workspace -w /workspace \
  ghcr.io/jinalshah/devops/images/all-devops:latest \
  sh -c "cd terraform && tflint --init && tflint"

# Lint Ansible
docker run --rm -v $PWD:/workspace -w /workspace \
  ghcr.io/jinalshah/devops/images/all-devops:latest \
  ansible-lint ansible/
```

### Kubernetes Operations

```bash
# Get pods
docker run --rm -v ~/.kube:/root/.kube \
  ghcr.io/jinalshah/devops/images/all-devops:latest \
  kubectl get pods

# Deploy with Helm
docker run --rm -v ~/.kube:/root/.kube -v $PWD:/workspace -w /workspace \
  ghcr.io/jinalshah/devops/images/all-devops:latest \
  helm upgrade --install myapp ./charts/myapp

# Interactive k9s
docker run -it --rm -v ~/.kube:/root/.kube \
  ghcr.io/jinalshah/devops/images/all-devops:latest \
  k9s
```

### AI-Assisted Development

```bash
# Code review with Claude
docker run --rm \
  -v $PWD:/workspace \
  -v ~/.claude:/root/.claude \
  -w /workspace \
  ghcr.io/jinalshah/devops/images/all-devops:latest \
  claude "Review this code for security issues" --file main.tf

# Generate code
docker run --rm \
  -v $PWD:/workspace \
  -v ~/.claude:/root/.claude \
  -w /workspace \
  ghcr.io/jinalshah/devops/images/all-devops:latest \
  claude "Generate Terraform code for AWS VPC" > vpc.tf
```

---

## Useful Aliases

Add to your `~/.bashrc` or `~/.zshrc`:

```bash
# Quick access to all-devops
alias devops='docker run -it --rm \
  -v $PWD:/workspace \
  -v ~/.aws:/root/.aws \
  -v ~/.config/gcloud:/root/.config/gcloud \
  -v ~/.ssh:/root/.ssh \
  -v ~/.kube:/root/.kube \
  -w /workspace \
  ghcr.io/jinalshah/devops/images/all-devops:latest'

# One-off commands
alias devops-run='docker run --rm \
  -v $PWD:/workspace \
  -v ~/.aws:/root/.aws \
  -v ~/.config/gcloud:/root/.config/gcloud \
  -w /workspace \
  ghcr.io/jinalshah/devops/images/all-devops:latest'

# Terraform-specific
alias tf-plan='devops-run terraform plan'
alias tf-apply='devops-run terraform apply'
alias tf-destroy='devops-run terraform destroy'

# Security scanning
alias trivy-scan='devops-run trivy config .'
alias tflint-scan='devops-run sh -c "tflint --init && tflint"'

# Kubernetes
alias k='docker run --rm -v ~/.kube:/root/.kube ghcr.io/jinalshah/devops/images/all-devops:latest kubectl'
alias k9s='docker run -it --rm -v ~/.kube:/root/.kube ghcr.io/jinalshah/devops/images/all-devops:latest k9s'
```

**Usage examples**:

```bash
# Interactive shell
devops

# Run Terraform
tf-plan
tf-apply

# Get pods
k get pods

# Scan for vulnerabilities
trivy-scan
```

---

## Tool Version Checks

```bash
# Check all versions
docker run --rm ghcr.io/jinalshah/devops/images/all-devops:latest sh -c "\
  echo '=== Terraform ===' && terraform version && \
  echo '=== kubectl ===' && kubectl version --client && \
  echo '=== Helm ===' && helm version && \
  echo '=== Ansible ===' && ansible --version && \
  echo '=== AWS CLI ===' && aws --version && \
  echo '=== gcloud ===' && gcloud --version && \
  echo '=== Trivy ===' && trivy --version && \
  echo '=== Python ===' && python3 --version && \
  echo '=== Node.js ===' && node --version"
```

---

## Environment Variables

### AWS

```bash
docker run --rm \
  -e AWS_ACCESS_KEY_ID=... \
  -e AWS_SECRET_ACCESS_KEY=... \
  -e AWS_DEFAULT_REGION=us-east-1 \
  -v $PWD:/workspace -w /workspace \
  ghcr.io/jinalshah/devops/images/all-devops:latest \
  terraform apply
```

### GCP

```bash
docker run --rm \
  -e GOOGLE_APPLICATION_CREDENTIALS=/tmp/key.json \
  -v $PWD:/workspace -w /workspace \
  -v /path/to/key.json:/tmp/key.json \
  ghcr.io/jinalshah/devops/images/all-devops:latest \
  terraform apply
```

### AI CLIs

```bash
docker run --rm \
  -e ANTHROPIC_API_KEY=sk-ant-... \
  -e OPENAI_API_KEY=sk-... \
  -v $PWD:/workspace -w /workspace \
  ghcr.io/jinalshah/devops/images/all-devops:latest \
  claude "Review this code" --file main.tf
```

---

## Image Sizes

| Image | Size | Use Case |
|-------|------|----------|
| **all-devops** | ~3.2 GB | Multi-cloud (AWS + GCP) |
| **aws-devops** | ~2.8 GB | AWS only (-400 MB) |
| **gcp-devops** | ~2.9 GB | GCP only (-300 MB) |

---

## Registry URLs

### GHCR (Recommended)

```bash
# All-devops
ghcr.io/jinalshah/devops/images/all-devops:latest
ghcr.io/jinalshah/devops/images/all-devops:1.0.abc1234

# AWS-devops
ghcr.io/jinalshah/devops/images/aws-devops:latest

# GCP-devops
ghcr.io/jinalshah/devops/images/gcp-devops:latest
```

### GitLab Registry

```bash
registry.gitlab.com/jinal-shah/devops/images/all-devops:latest
registry.gitlab.com/jinal-shah/devops/images/aws-devops:latest
registry.gitlab.com/jinal-shah/devops/images/gcp-devops:latest
```

### Docker Hub

```bash
js01/all-devops:latest
js01/aws-devops:latest
js01/gcp-devops:latest
```

---

## Keyboard Shortcuts

### Inside k9s

| Key | Action |
|-----|--------|
| `0` | Show all pods |
| `d` | Describe resource |
| `l` | Show logs |
| `s` | Open shell |
| `/` | Filter |
| `:q` | Quit |

### Inside vim

| Key | Action |
|-----|--------|
| `:w` | Save |
| `:q` | Quit |
| `:wq` | Save and quit |
| `/` | Search |
| `dd` | Delete line |
| `u` | Undo |

---

## Quick Troubleshooting

### Image won't pull

```bash
# Try different registry
docker pull ghcr.io/jinalshah/devops/images/all-devops:latest  # GHCR
docker pull registry.gitlab.com/jinal-shah/devops/images/all-devops:latest  # GitLab
docker pull js01/all-devops:latest  # Docker Hub
```

### Permissions issues

```bash
# Run with your user ID
docker run --rm \
  --user "$(id -u):$(id -g)" \
  -v $PWD:/workspace -w /workspace \
  ghcr.io/jinalshah/devops/images/all-devops:latest \
  terraform fmt

# Or fix ownership after
sudo chown -R $(id -u):$(id -g) .
```

### Credentials not working

```bash
# Verify mount
docker run --rm -v ~/.aws:/root/.aws \
  ghcr.io/jinalshah/devops/images/all-devops:latest \
  ls -la /root/.aws

# Test authentication
docker run --rm -v ~/.aws:/root/.aws \
  ghcr.io/jinalshah/devops/images/all-devops:latest \
  aws sts get-caller-identity
```

---

## Performance Tips

### Cache Docker Layers

```bash
# Pull once
docker pull ghcr.io/jinalshah/devops/images/all-devops:1.0.abc1234

# Reuse for all commands (layers cached)
docker run --rm ... ghcr.io/jinalshah/devops/images/all-devops:1.0.abc1234
```

### Cache Terraform Plugins

```bash
# Cache plugins directory
docker run --rm \
  -v $PWD:/workspace \
  -v ~/.terraform.d:/root/.terraform.d \
  -w /workspace \
  ghcr.io/jinalshah/devops/images/all-devops:latest \
  terraform init
```

### Use Named Containers

```bash
# Create named container
docker run -it --name devops-work \
  -v $PWD:/workspace \
  -w /workspace \
  ghcr.io/jinalshah/devops/images/all-devops:latest

# Restart later
docker start -i devops-work
```

---

## Next Steps

- [Authentication Setup](authentication.md) - Configure cloud credentials
- [Docker Compose Examples](docker-compose.md) - Multi-container setups
- [Tool Basics](../tool-basics/index.md) - Detailed tool documentation
- [Workflows](../workflows/index.md) - Real-world examples
