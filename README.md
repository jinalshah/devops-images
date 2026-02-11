# DevOps Images

[![Build and Push](https://github.com/jinalshah/devops-images/actions/workflows/image-builder.yml/badge.svg)](https://github.com/jinalshah/devops-images/actions/workflows/image-builder.yml)

Multi-architecture container images with a comprehensive DevOps toolchain for AWS, GCP, and platform engineering workflows. Built on Rocky Linux 9 with support for both `linux/amd64` and `linux/arm64` architectures.

## Available Images

| Image | Description | Cloud Tools | Best For |
|-------|-------------|-------------|----------|
| **all-devops** | Full toolkit with AWS + GCP | AWS CLI, gcloud, Session Manager | Multi-cloud teams, platform engineering |
| **aws-devops** | AWS-optimized image | AWS CLI, Session Manager | AWS-focused operations |
| **gcp-devops** | GCP-optimized image | gcloud, GKE tools | GCP-focused operations |

### Base Tools (All Images)

**Infrastructure as Code:**
- Terraform (with tfswitch for version management)
- Terragrunt
- TFLint
- Packer

**Kubernetes & Containers:**
- kubectl (latest stable)
- Helm 3
- k9s (terminal UI)

**Configuration Management:**
- Ansible & ansible-lint
- pre-commit hooks

**Security:**
- Trivy (vulnerability scanner)

**Development Tools:**
- Python 3.12 (with pip)
- Node.js LTS (with npm)
- Git & GitHub CLI (gh)
- Task (go-task)
- ghorg (GitHub organization cloner)

**AI Code Assistants:**
- Claude CLI
- OpenAI Codex CLI
- GitHub Copilot CLI
- Google Gemini CLI

**Database Clients:**
- MongoDB Shell (mongosh) - v6.0
- PostgreSQL client (psql) - v17
- MySQL client

**Network & Diagnostic Tools:**
- dig, nslookup, ncat, telnet
- curl, wget
- jq (JSON processor)

**Shells:**
- Zsh (default, with Oh My Zsh + candy theme)
- Bash
- Fish

## Supported Architectures

All images support multi-platform builds:
- `linux/amd64` (x86_64)
- `linux/arm64` (ARM64/Apple Silicon)

Docker automatically pulls the correct architecture for your platform.

## Container Registries

Images are published to three registries for redundancy and accessibility:

| Registry | Image Path |
|----------|------------|
| **GitHub Container Registry (GHCR)** | `ghcr.io/jinalshah/devops/images/<image>:<tag>` |
| **GitLab Container Registry** | `registry.gitlab.com/jinal-shah/devops/images/<image>:<tag>` |
| **Docker Hub** | `js01/<image>:<tag>` |

Replace `<image>` with `all-devops`, `aws-devops`, or `gcp-devops`.

### Tagging Strategy

- **Version tags**: `1.0.<sha7>` (immutable, recommended for CI/CD)
- **Architecture-specific**: `1.0.<sha7>-amd64`, `1.0.<sha7>-arm64`
- **latest**: Only updated on `main` branch (use for development)

## Quick Start

### Pull an Image

```bash
# Pull from GitHub Container Registry (recommended)
docker pull ghcr.io/jinalshah/devops/images/all-devops:latest

# Or from GitLab Container Registry
docker pull registry.gitlab.com/jinal-shah/devops/images/all-devops:latest

# Or from Docker Hub
docker pull js01/all-devops:latest
```

### Run Interactively

**Basic usage:**

```bash
docker run -it --rm ghcr.io/jinalshah/devops/images/all-devops:latest
```

**Production usage** (with volume mounts for credentials and project files):

```bash
docker run -it --name devops-container \
  -v $PWD:/srv \
  -v ~/.ssh:/root/.ssh \
  -v ~/.aws:/root/.aws \
  -v ~/.config/gcloud:/root/.config/gcloud \
  -v ~/.claude:/root/.claude \
  -v ~/.codex:/root/.codex \
  -v ~/.copilot:/root/.copilot \
  -v ~/.gemini:/root/.gemini \
  ghcr.io/jinalshah/devops/images/all-devops:latest
```

### Run Single Commands

```bash
# Check Terraform version
docker run --rm ghcr.io/jinalshah/devops/images/all-devops:latest terraform version

# Run Ansible playbook
docker run --rm -v $PWD:/srv ghcr.io/jinalshah/devops/images/all-devops:latest \
  ansible-playbook /srv/playbook.yml

# Scan with Trivy
docker run --rm ghcr.io/jinalshah/devops/images/all-devops:latest \
  trivy image nginx:latest
```

## Use Cases

### For Developers

- **Consistent Development Environment**: No need to install dozens of tools locally
- **Multi-version Testing**: Test IaC code across different tool versions
- **Clean Workspace**: Isolated environment that doesn't pollute your host system

### For CI/CD Pipelines

- **GitHub Actions**: Use as a container for workflow jobs
- **GitLab CI**: Reference as base image in `.gitlab-ci.yml`
- **Jenkins**: Run in Docker agents with all tools pre-installed
- **Reproducible Builds**: Pin to specific version tags for consistency

### For Teams

- **Standardized Toolchain**: Everyone uses the same tool versions
- **Onboarding**: New team members start productive immediately
- **Multi-cloud Operations**: Single image for AWS and GCP workflows

## Build Images Locally

### Build a Specific Image

```bash
# Build all-devops
docker build --target all-devops -t all-devops:local .

# Build aws-devops
docker build --target aws-devops -t aws-devops:local .

# Build gcp-devops
docker build --target gcp-devops -t gcp-devops:local .
```

### Build All Images

```bash
for target in all-devops aws-devops gcp-devops; do
  docker build --target "$target" -t "$target:local" .
done
```

### Build Multi-Architecture Images

```bash
# Create buildx builder
docker buildx create --name multiarch --use

# Build for both AMD64 and ARM64
docker buildx build \
  --platform linux/amd64,linux/arm64 \
  --target all-devops \
  -t all-devops:multi \
  --load .
```

### Customize Build

Override tool versions using build arguments:

```bash
docker build --target all-devops \
  --build-arg TERRAFORM_VERSION=1.7.0 \
  --build-arg PYTHON_VERSION=3.12.4 \
  --build-arg K9S_VERSION=0.32.7 \
  -t all-devops:custom .
```

Available build args: `GCLOUD_VERSION`, `PACKER_VERSION`, `TERRAGRUNT_VERSION`, `TFLINT_VERSION`, `GHORG_VERSION`, `K9S_VERSION`, `PYTHON_VERSION`, `MONGODB_VERSION`

## Examples

### Using in GitHub Actions

```yaml
name: Deploy Infrastructure

on: [push]

jobs:
  terraform:
    runs-on: ubuntu-latest
    container:
      image: ghcr.io/jinalshah/devops/images/all-devops:1.0.abc1234
    steps:
      - uses: actions/checkout@v4

      - name: Terraform Init
        run: terraform init

      - name: Terraform Plan
        run: terraform plan

      - name: Terraform Apply
        if: github.ref == 'refs/heads/main'
        run: terraform apply -auto-approve
```

### Using with Docker Compose

```yaml
version: '3.8'

services:
  devops:
    image: ghcr.io/jinalshah/devops/images/all-devops:latest
    volumes:
      - .:/workspace
      - ~/.aws:/root/.aws
      - ~/.ssh:/root/.ssh
    working_dir: /workspace
    command: /bin/zsh
    stdin_open: true
    tty: true
```

### Interactive Development

```bash
# Start container with persistent name
docker run -it --name my-devops \
  -v $PWD:/workspace \
  -v ~/.aws:/root/.aws \
  -w /workspace \
  ghcr.io/jinalshah/devops/images/all-devops:latest

# Later, restart the same container
docker start -ai my-devops
```

## Version Pinning for Production

For CI/CD and production use, always pin to specific version tags:

```bash
# Good - immutable version tag
docker pull ghcr.io/jinalshah/devops/images/all-devops:1.0.abc1234

# Avoid in production - mutable tag
docker pull ghcr.io/jinalshah/devops/images/all-devops:latest
```

Version tags follow the pattern `1.0.<sha7>` where `sha7` is the short Git commit hash.

## Platform-Specific Notes

### Apple Silicon (M1/M2/M3)

Images automatically use the ARM64 variant on Apple Silicon Macs:

```bash
docker pull ghcr.io/jinalshah/devops/images/all-devops:latest
docker run --rm ghcr.io/jinalshah/devops/images/all-devops:latest uname -m
# Output: aarch64
```

### Linux AMD64

On x86_64 Linux systems, the AMD64 variant is pulled automatically:

```bash
docker run --rm ghcr.io/jinalshah/devops/images/all-devops:latest uname -m
# Output: x86_64
```

## Troubleshooting

### Files Created as Root

When running commands that create files, they're owned by root. Use `--user` to match host permissions:

```bash
docker run --rm --user "$(id -u):$(id -g)" \
  -v $PWD:/srv \
  ghcr.io/jinalshah/devops/images/all-devops:latest \
  terraform fmt -recursive /srv
```

### Authentication Issues

If you encounter authentication issues with cloud providers:

```bash
# AWS - verify credentials are mounted
docker run --rm -v ~/.aws:/root/.aws \
  ghcr.io/jinalshah/devops/images/aws-devops:latest \
  aws sts get-caller-identity

# GCP - verify gcloud config is mounted
docker run --rm -v ~/.config/gcloud:/root/.config/gcloud \
  ghcr.io/jinalshah/devops/images/gcp-devops:latest \
  gcloud auth list
```

### AI CLI Authentication

AI tools require separate authentication setup. Mount the config directories:

```bash
# First, authenticate on your host machine
claude auth login
codex auth login
gh copilot auth

# Then mount configs when running container
docker run -it \
  -v ~/.claude:/root/.claude \
  -v ~/.codex:/root/.codex \
  -v ~/.copilot:/root/.copilot \
  ghcr.io/jinalshah/devops/images/all-devops:latest
```

## Documentation

### Published Documentation

Complete documentation is available at: **[https://jinalshah.github.io/devops-images/](https://jinalshah.github.io/devops-images/)**

Documentation includes:

- **[Getting Started Guide](https://jinalshah.github.io/devops-images/)** - Quick start and overview
- **[Using Images](https://jinalshah.github.io/devops-images/use-images/)** - Pull, run, and automation patterns
- **[Building Images](https://jinalshah.github.io/devops-images/build-images/)** - Local builds and customization
- **[Tool Basics](https://jinalshah.github.io/devops-images/tool-basics/)** - Comprehensive tool reference with examples
- **[Troubleshooting](https://jinalshah.github.io/devops-images/troubleshooting/)** - Common issues and solutions

### Preview Documentation Locally

```bash
# Install mkdocs-material
python3 -m pip install --upgrade mkdocs-material

# Serve documentation
mkdocs serve

# Open http://localhost:8000
```

Or preview using the container itself:

```bash
docker run --rm -it -p 8000:8000 \
  -v $PWD:/workspace \
  ghcr.io/jinalshah/devops/images/all-devops:latest \
  sh -c "cd /workspace && mkdocs serve -a 0.0.0.0:8000"
```

## Contributing

Contributions are welcome! Please:

1. Open an issue to discuss significant changes
2. Ensure builds pass locally before submitting PR
3. Update documentation for new features
4. Follow existing code style and conventions

## License

This project is open source. See repository for license details.

## Related Projects

- [Terraform](https://www.terraform.io/) - Infrastructure as Code
- [Ansible](https://www.ansible.com/) - Configuration management
- [Trivy](https://trivy.dev/) - Security scanner
- [kubectl](https://kubernetes.io/docs/reference/kubectl/) - Kubernetes CLI
- [GitHub CLI](https://cli.github.com/) - GitHub from the command line
