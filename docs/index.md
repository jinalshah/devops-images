# Getting Started

Welcome to the DevOps Images documentation! This project provides production-ready, multi-architecture container images packed with essential DevOps tools for cloud infrastructure, automation, and platform engineering.

## What Are These Images?

DevOps Images are pre-built Docker containers that include a comprehensive toolkit for:

- **Infrastructure as Code** (Terraform, Terragrunt, Packer)
- **Kubernetes Operations** (kubectl, Helm, k9s)
- **Configuration Management** (Ansible, pre-commit)
- **Security Scanning** (Trivy)
- **Cloud Provider CLIs** (AWS CLI, gcloud)
- **AI Code Assistants** (Claude, Codex, Copilot, Gemini)
- **Database Clients** (mongosh, psql, mysql)
- **Development Tools** (Python, Node.js, Git, GitHub CLI)

Built on **Rocky Linux 9** with support for both **AMD64** and **ARM64** architectures, these images eliminate the need to install dozens of tools on your local machine or CI/CD runners.

## Choose the Right Image

| Image | Best For | Cloud Tools | Size |
|-------|----------|-------------|------|
| **all-devops** | Multi-cloud teams, platform engineering, one-stop solution | AWS CLI + gcloud + Session Manager | Largest |
| **aws-devops** | AWS-focused DevOps, smaller footprint than all-devops | AWS CLI + Session Manager | Medium |
| **gcp-devops** | GCP-focused DevOps, smaller footprint than all-devops | gcloud + GKE tools | Medium |

### Common Base Tools (All Images)

**Infrastructure as Code:**

- Terraform with tfswitch for version management
- Terragrunt for DRY configurations
- TFLint for linting
- Packer for image building

**Kubernetes & Containers:**

- kubectl (latest stable)
- Helm 3
- k9s terminal UI

**Configuration & Automation:**

- Ansible & ansible-lint
- pre-commit hooks
- Task (go-task) runner

**Security & Quality:**

- Trivy vulnerability scanner

**Development:**

- Python 3.12 with pip
- Node.js LTS with npm
- Git & GitHub CLI
- ghorg (GitHub org cloner)

**AI Code Assistants:**

- Claude CLI
- OpenAI Codex CLI
- GitHub Copilot CLI
- Google Gemini CLI

**Database Clients:**

- MongoDB Shell (mongosh) v6.0
- PostgreSQL (psql) v17
- MySQL client

**Network & Diagnostics:**

- dig, nslookup, ncat, telnet
- curl, wget
- jq JSON processor

**Shells:**

- Zsh (default, with Oh My Zsh)
- Bash
- Fish

## Why Use These Images?

### For Individual Developers

✓ **No local tool installation** - Everything pre-configured and ready to use
✓ **Consistent environment** - Same tools and versions across your team
✓ **Clean host system** - Keep development tools isolated in containers
✓ **Multi-version testing** - Test against different tool versions easily
✓ **Cross-platform** - Works on AMD64 Linux, macOS, and Apple Silicon

### For Teams

✓ **Standardised toolchain** - Everyone uses identical tool versions
✓ **Fast onboarding** - New team members productive in minutes
✓ **Multi-cloud ready** - Single image for AWS, GCP, and Kubernetes
✓ **Version controlled** - Pin to specific image tags for reproducibility

### For CI/CD Pipelines

✓ **Pre-built and cached** - Faster pipeline execution
✓ **Immutable tags** - Reproducible builds with version pinning
✓ **Multi-arch support** - Works with ARM and x86 runners
✓ **Regular updates** - Weekly automated builds with latest tools

## Available Registries

Images are published to three container registries for redundancy and global availability:

| Registry | Image Path | Best For |
|----------|------------|----------|
| **GitHub Container Registry (GHCR)** | `ghcr.io/jinalshah/devops/images/<image>:<tag>` | Primary, recommended for most users |
| **GitLab Container Registry** | `registry.gitlab.com/jinal-shah/devops/images/<image>:<tag>` | GitLab CI/CD pipelines |
| **Docker Hub** | `js01/<image>:<tag>` | Alternative, rate-limit considerations |

Replace `<image>` with `all-devops`, `aws-devops`, or `gcp-devops`.

## Quick Start Guide

### Step 1: Pull an Image

Choose your preferred registry and pull the image:

```bash
# From GHCR (recommended)
docker pull ghcr.io/jinalshah/devops/images/all-devops:latest

# From GitLab
docker pull registry.gitlab.com/jinal-shah/devops/images/all-devops:latest

# From Docker Hub
docker pull js01/all-devops:latest
```

### Step 2: Run the Container

**Simple interactive session:**

```bash
docker run -it --rm ghcr.io/jinalshah/devops/images/all-devops:latest
```

This drops you into a Zsh shell with all tools available.

**Production-ready setup with volume mounts:**

```bash
docker run -it --name devops-work \
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

**Volume mount explanations:**

- `-v $PWD:/srv` - Mount current directory as `/srv` for accessing your project files
- `-v ~/.ssh:/root/.ssh` - Mount SSH keys for Git and remote access
- `-v ~/.aws:/root/.aws` - Mount AWS credentials (for AWS images)
- `-v ~/.config/gcloud:/root/.config/gcloud` - Mount GCP credentials (for GCP images)
- AI CLI mounts - Required for authenticated AI assistant access

### Step 3: Verify Tools

Once inside the container, verify tools are working:

```bash
# Infrastructure tools
terraform version
kubectl version --client
ansible --version

# Cloud CLIs (if using all-devops or cloud-specific images)
aws --version      # AWS images
gcloud --version   # GCP images

# Security and quality
trivy --version

# Development tools
python3 --version
node --version
git --version
```

## Image Tags and Versioning

### Tag Types

The CI pipeline publishes multiple tag types:

| Tag Type | Example | Description | Use For |
|----------|---------|-------------|---------|
| **Version** | `1.0.abc1234` | Immutable, based on Git commit | Production, CI/CD |
| **Arch-specific** | `1.0.abc1234-amd64` | Single architecture | Debugging arch issues |
| **Latest** | `latest` | Points to latest main build | Development only |

### Multi-Architecture Support

All images support both architectures:

- **linux/amd64** (x86_64) - Traditional Intel/AMD processors
- **linux/arm64** (aarch64) - ARM processors, Apple Silicon (M1/M2/M3)

Docker automatically pulls the correct architecture for your platform.

### Best Practices

**For CI/CD and Production:**

```bash
# ✅ Good - immutable version tag
docker pull ghcr.io/jinalshah/devops/images/all-devops:1.0.abc1234
```

**For Local Development:**

```bash
# ✅ Acceptable - always get latest tools
docker pull ghcr.io/jinalshah/devops/images/all-devops:latest
```

**Avoid in Production:**

```bash
# ❌ Avoid - tag changes over time, not reproducible
docker pull ghcr.io/jinalshah/devops/images/all-devops:latest
```

## Common Use Cases

### Use Case 1: Interactive Development

Perfect for working on infrastructure code without installing tools locally:

```bash
docker run -it --rm \
  -v $PWD:/workspace \
  -v ~/.aws:/root/.aws \
  -w /workspace \
  ghcr.io/jinalshah/devops/images/aws-devops:latest
```

Now you can run `terraform`, `ansible`, `kubectl` commands on your project files.

### Use Case 2: CI/CD Pipeline

Use as a base container in GitHub Actions:

```yaml
jobs:
  deploy:
    runs-on: ubuntu-latest
    container:
      image: ghcr.io/jinalshah/devops/images/all-devops:1.0.abc1234
    steps:
      - uses: actions/checkout@v4
      - run: terraform init
      - run: terraform apply -auto-approve
```

### Use Case 3: One-off Commands

Run tools without entering the container:

```bash
# Format Terraform files
docker run --rm -v $PWD:/srv \
  ghcr.io/jinalshah/devops/images/all-devops:latest \
  terraform fmt -recursive /srv

# Scan for vulnerabilities
docker run --rm \
  ghcr.io/jinalshah/devops/images/all-devops:latest \
  trivy image nginx:latest

# Run Ansible playbook
docker run --rm -v $PWD:/srv \
  ghcr.io/jinalshah/devops/images/all-devops:latest \
  ansible-playbook /srv/playbook.yml
```

### Use Case 4: Team Standardization

Create a team-specific wrapper script:

```bash
#!/bin/bash
# ~/bin/devops

docker run -it --rm \
  -v $PWD:/workspace \
  -v ~/.ssh:/root/.ssh \
  -v ~/.aws:/root/.aws \
  -w /workspace \
  ghcr.io/jinalshah/devops/images/all-devops:1.0.abc1234 \
  "$@"
```

Now team members can run: `devops terraform plan`

## Next Steps

Choose your path based on what you want to accomplish:

### I want to use pre-built images

→ **[Using the Images](use-images/index.md)** - Pull, run, and integrate with workflows

- [All DevOps Image](use-images/all-devops.md) - Multi-cloud usage
- [AWS DevOps Image](use-images/aws-devops.md) - AWS-specific usage
- [GCP DevOps Image](use-images/gcp-devops.md) - GCP-specific usage

### I want to build images locally

→ **[Building Images](build-images/index.md)** - Build, customise, and test locally

- [Building All DevOps](build-images/all-devops.md)
- [Building AWS DevOps](build-images/aws-devops.md)
- [Building GCP DevOps](build-images/gcp-devops.md)
- [Multi-platform Builds](build-images/multi-platform-images.md) - Advanced build workflows

### I want to learn about the tools

→ **[Tool Basics](tool-basics/index.md)** - Comprehensive tool reference

- Detailed descriptions of every tool
- Basic to advanced usage examples
- Common use cases and patterns

### I'm having issues

→ **[Troubleshooting](troubleshooting/index.md)** - Common problems and solutions

- Pull and authentication issues
- Container runtime problems
- Build failures
- Platform-specific issues

## Documentation Structure

```
Getting Started (you are here)
├── Using Images
│   ├── Overview and common patterns
│   ├── All DevOps image
│   ├── AWS DevOps image
│   └── GCP DevOps image
├── Building Images
│   ├── Local builds
│   ├── Build customization
│   ├── Multi-platform builds
│   └── Image-specific builds
├── Tool Basics
│   └── Comprehensive tool reference
└── Troubleshooting
    └── Common issues and solutions
```

## Getting Help

- **Documentation issues**: [Open an issue](https://github.com/jinalshah/devops-images/issues/new) on GitHub
- **Tool-specific help**: Refer to the [Tool Basics](tool-basics/index.md) section
- **Build problems**: Check the [Troubleshooting](troubleshooting/index.md) guide

## Quick Links

- [GitHub Repository](https://github.com/jinalshah/devops-images)
- [GitHub Container Registry](https://github.com/jinalshah/devops-images/pkgs/container/devops%2Fimages%2Fall-devops)
- [CI/CD Workflows](https://github.com/jinalshah/devops-images/actions)
