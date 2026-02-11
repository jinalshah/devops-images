# GCP DevOps Image

GCP-optimized container with all essential DevOps tools plus Google Cloud-specific CLIs. Perfect for GCP-centric workflows while maintaining full platform tool support.

---

## Pull the Image

=== "GHCR (Recommended)"

    ```bash
    # Latest version
    docker pull ghcr.io/jinalshah/devops/images/gcp-devops:latest

    # Specific version (recommended for CI/CD)
    docker pull ghcr.io/jinalshah/devops/images/gcp-devops:1.0.abc1234
    ```

    !!! tip "Why GHCR?"
        - **No rate limits** for public images
        - **Built-in GitHub integration** for CI/CD
        - **Faster pulls** from GitHub Actions

=== "GitLab Registry"

    ```bash
    # Latest version
    docker pull registry.gitlab.com/jinal-shah/devops/images/gcp-devops:latest

    # Specific version
    docker pull registry.gitlab.com/jinal-shah/devops/images/gcp-devops:1.0.abc1234
    ```

    !!! tip "When to use"
        - Using GitLab CI/CD pipelines
        - Need GitLab Container Registry integration
        - Already authenticated with GitLab

=== "Docker Hub"

    ```bash
    # Latest version
    docker pull js01/gcp-devops:latest

    # Specific version
    docker pull js01/gcp-devops:1.0.abc1234
    ```

    !!! warning "Rate Limits"
        Docker Hub has pull rate limits for free accounts:

        - **Unauthenticated**: 100 pulls per 6 hours
        - **Authenticated**: 200 pulls per 6 hours

        Consider using GHCR for CI/CD to avoid rate limit issues.

---

## What's Included

### Base Platform Tools

All standard DevOps tools from the base image:

- **Infrastructure as Code**: Terraform, Terragrunt, TFLint, Packer
- **Kubernetes**: kubectl, Helm 3, k9s, kustomize
- **Security**: Trivy (container scanning), ansible-lint
- **Configuration Management**: Ansible
- **Development**: Python 3.12, Node.js 20, Git, jq, yq
- **AI CLIs**: claude, codex, copilot, gemini
- **Utilities**: gh (GitHub CLI), Task, zsh, vim, curl, wget

### GCP-Specific Additions

Tools optimized for Google Cloud workflows:

- **Google Cloud CLI (`gcloud`)**: Complete GCP command-line suite
  - `gcloud` - Core Cloud SDK
  - `gsutil` - Cloud Storage operations
  - `bq` - BigQuery CLI
- **Docker Credential Helper**: `docker-credential-gcr` for GCR authentication

---

## Quick Start

### Interactive Shell

```bash
# Basic interactive shell with GCP credentials
docker run -it --rm \
  -v $PWD:/workspace \  # (1)!
  -v ~/.config/gcloud:/root/.config/gcloud \  # (2)!
  -w /workspace \  # (3)!
  ghcr.io/jinalshah/devops/images/gcp-devops:latest
```

1. Mount current directory to `/workspace` for file access
2. Mount GCP credentials for authentication
3. Set working directory to your project

### One-Off Commands

=== "gcloud CLI"

    ```bash
    # Verify GCP identity
    docker run --rm \
      -v ~/.config/gcloud:/root/.config/gcloud \
      ghcr.io/jinalshah/devops/images/gcp-devops:latest \
      gcloud auth list

    # List GCP projects
    docker run --rm \
      -v ~/.config/gcloud:/root/.config/gcloud \
      ghcr.io/jinalshah/devops/images/gcp-devops:latest \
      gcloud projects list
    ```

=== "Terraform + GCP"

    ```bash
    # Terraform plan with GCP credentials
    docker run --rm \
      -v $PWD:/workspace \
      -v ~/.config/gcloud:/root/.config/gcloud \
      -w /workspace \
      ghcr.io/jinalshah/devops/images/gcp-devops:latest \
      terraform plan

    # Terraform apply
    docker run --rm \
      -v $PWD:/workspace \
      -v ~/.config/gcloud:/root/.config/gcloud \
      -w /workspace \
      ghcr.io/jinalshah/devops/images/gcp-devops:latest \
      terraform apply -auto-approve
    ```

=== "Cloud Storage"

    ```bash
    # List Cloud Storage buckets
    docker run --rm \
      -v ~/.config/gcloud:/root/.config/gcloud \
      ghcr.io/jinalshah/devops/images/gcp-devops:latest \
      gsutil ls

    # Upload file to bucket
    docker run --rm \
      -v $PWD:/workspace \
      -v ~/.config/gcloud:/root/.config/gcloud \
      -w /workspace \
      ghcr.io/jinalshah/devops/images/gcp-devops:latest \
      gsutil cp myfile.txt gs://my-bucket/
    ```

=== "GKE Operations"

    ```bash
    # Get GKE cluster credentials
    docker run --rm \
      -v ~/.config/gcloud:/root/.config/gcloud \
      -v ~/.kube:/root/.kube \
      ghcr.io/jinalshah/devops/images/gcp-devops:latest \
      gcloud container clusters get-credentials my-cluster \
        --region us-central1

    # List pods in GKE cluster
    docker run --rm \
      -v ~/.kube:/root/.kube \
      ghcr.io/jinalshah/devops/images/gcp-devops:latest \
      kubectl get pods -A
    ```

---

## Authentication Methods

### Method 1: Mount gcloud Config (Recommended)

```bash
docker run -it --rm \
  -v ~/.config/gcloud:/root/.config/gcloud \  # (1)!
  ghcr.io/jinalshah/devops/images/gcp-devops:latest \
  gcloud auth list
```

1. Mounts your local gcloud configuration including credentials and active project

**What's mounted**:
- Authentication tokens
- Active project configuration
- Component settings

**Initial setup** (run once on your local machine):
```bash
gcloud auth login
gcloud config set project YOUR_PROJECT_ID
```

### Method 2: Service Account Key File

```bash
docker run -it --rm \
  -v /path/to/key.json:/tmp/key.json \  # (1)!
  -e GOOGLE_APPLICATION_CREDENTIALS=/tmp/key.json \  # (2)!
  ghcr.io/jinalshah/devops/images/gcp-devops:latest \
  gcloud auth list
```

1. Mount service account JSON key file
2. Set environment variable pointing to the key

!!! warning "Security"
    Service account keys are sensitive credentials. Never commit them to version control. Use secret management in CI/CD.

**Activate service account**:
```bash
docker run --rm \
  -v /path/to/key.json:/tmp/key.json \
  ghcr.io/jinalshah/devops/images/gcp-devops:latest \
  gcloud auth activate-service-account --key-file=/tmp/key.json
```

### Method 3: Workload Identity (GKE)

When running on GKE with Workload Identity enabled, the container automatically inherits GCP credentials:

```bash
# No credentials needed - uses Workload Identity
docker run -it --rm \
  ghcr.io/jinalshah/devops/images/gcp-devops:latest \
  gcloud auth list
```

**Supported GCP environments**:
- GKE pods with Workload Identity
- Cloud Run services
- Compute Engine with default service account
- Cloud Build

---

## Common Workflows

### Terraform on GCP

```bash
#!/bin/bash
# Deploy infrastructure to GCP

docker run --rm \
  -v $PWD:/workspace \
  -v ~/.config/gcloud:/root/.config/gcloud \
  -w /workspace \
  ghcr.io/jinalshah/devops/images/gcp-devops:latest \
  sh -c "
    terraform init
    terraform validate
    terraform plan -out=tfplan
    terraform apply tfplan
  "
```

### Deploy to GKE with Helm

```bash
# Get GKE credentials and deploy
docker run --rm \
  -v $PWD:/workspace \
  -v ~/.config/gcloud:/root/.config/gcloud \
  -v ~/.kube:/root/.kube \
  -w /workspace \
  ghcr.io/jinalshah/devops/images/gcp-devops:latest \
  sh -c "
    gcloud container clusters get-credentials prod-cluster --region us-central1
    helm upgrade --install myapp ./charts/myapp
  "
```

### Ansible with GCP Dynamic Inventory

```bash
# Run playbook against GCP instances
docker run --rm \
  -v $PWD:/workspace \
  -v ~/.config/gcloud:/root/.config/gcloud \
  -v ~/.ssh:/root/.ssh \  # (1)!
  -w /workspace \
  ghcr.io/jinalshah/devops/images/gcp-devops:latest \
  ansible-playbook \
    -i gcp_compute.yml \  # (2)!
    deploy.yml
```

1. Mount SSH keys for instance access
2. GCP compute dynamic inventory plugin

### Security Scanning

```bash
# Scan Terraform configs and container images
docker run --rm \
  -v $PWD:/workspace \
  -v ~/.config/gcloud:/root/.config/gcloud \
  -w /workspace \
  ghcr.io/jinalshah/devops/images/gcp-devops:latest \
  sh -c "
    trivy config terraform/
    trivy image gcr.io/my-project/my-app:latest
  "
```

### Cloud Storage Operations

```bash
# Sync directory to Cloud Storage
docker run --rm \
  -v $PWD:/workspace \
  -v ~/.config/gcloud:/root/.config/gcloud \
  -w /workspace \
  ghcr.io/jinalshah/devops/images/gcp-devops:latest \
  gsutil -m rsync -r ./build gs://my-bucket/releases/
```

---

## Best Use Cases

!!! success "Perfect For"

    - ✅ **GCP-first DevOps teams**: No AWS tools to reduce image size
    - ✅ **GCP-only CI/CD pipelines**: Faster startup than multi-cloud image
    - ✅ **GKE deployments**: gcloud + kubectl + Helm in one image
    - ✅ **Terraform on GCP**: Full Terraform + gcloud CLI integration
    - ✅ **Cloud Run deployments**: gcloud CLI with container runtime
    - ✅ **Cloud Build pipelines**: Optimized for GCP-native CI/CD

!!! info "Consider all-devops if you need"

    - Multi-cloud (AWS + GCP) support
    - AWS CLI for hybrid workflows
    - Team works across cloud providers

---

## Image Size

| Image | Size | GCP Tools |
|-------|------|-----------|
| **gcp-devops** | ~2.9 GB | gcloud SDK, gsutil, bq, docker-credential-gcr |
| all-devops | ~3.2 GB | GCP + AWS tools |

**Size savings**: ~300 MB compared to `all-devops` by excluding AWS-specific tools.

---

## Dockerfile Reference

Want to build your own? See [Building GCP DevOps Image](../build-images/gcp-devops.md) for:

- Complete Dockerfile
- Build arguments
- Customization options
- Multi-platform builds

---

## Advanced Usage

??? tip "Cache Terraform Plugins"

    Speed up repeated Terraform runs by caching provider plugins:

    ```bash
    docker run --rm \
      -v $PWD:/workspace \
      -v ~/.config/gcloud:/root/.config/gcloud \
      -v ~/.terraform.d:/root/.terraform.d \  # (1)!
      -w /workspace \
      ghcr.io/jinalshah/devops/images/gcp-devops:latest \
      terraform init
    ```

    1. Cache Terraform plugins across runs (saves download time)

??? tip "Named Container for Persistent Shell"

    Keep a persistent container for ongoing work:

    ```bash
    # Create named container
    docker run -it --name gcp-dev \
      -v $PWD:/workspace \
      -v ~/.config/gcloud:/root/.config/gcloud \
      -w /workspace \
      ghcr.io/jinalshah/devops/images/gcp-devops:latest

    # Later, restart the same container
    docker start -i gcp-dev
    ```

??? tip "Custom Shell Alias"

    Add to `~/.bashrc` or `~/.zshrc`:

    ```bash
    alias gcp-devops='docker run -it --rm \
      -v $PWD:/workspace \
      -v ~/.config/gcloud:/root/.config/gcloud \
      -v ~/.kube:/root/.kube \
      -v ~/.ssh:/root/.ssh \
      -w /workspace \
      ghcr.io/jinalshah/devops/images/gcp-devops:latest'

    # Usage
    gcp-devops terraform plan
    gcp-devops gcloud projects list
    gcp-devops kubectl get pods
    ```

??? tip "GCR Authentication for Docker"

    Authenticate Docker to use Google Container Registry:

    ```bash
    docker run --rm \
      -v ~/.config/gcloud:/root/.config/gcloud \
      -v ~/.docker:/root/.docker \
      ghcr.io/jinalshah/devops/images/gcp-devops:latest \
      gcloud auth configure-docker gcr.io
    ```

---

## Troubleshooting

??? question "GCP credentials not found"

    **Problem**: `ERROR: (gcloud.auth.list) Failed to load credentials`

    **Solutions**:

    1. Verify credentials exist locally:
       ```bash
       gcloud auth list
       ```

    2. Authenticate if needed:
       ```bash
       gcloud auth login
       gcloud config set project YOUR_PROJECT_ID
       ```

    3. Check mount is working:
       ```bash
       docker run --rm \
         -v ~/.config/gcloud:/root/.config/gcloud \
         ghcr.io/jinalshah/devops/images/gcp-devops:latest \
         ls -la /root/.config/gcloud
       ```

    4. Use service account key instead:
       ```bash
       docker run --rm \
         -v /path/to/key.json:/tmp/key.json \
         -e GOOGLE_APPLICATION_CREDENTIALS=/tmp/key.json \
         ghcr.io/jinalshah/devops/images/gcp-devops:latest \
         gcloud auth list
       ```

??? question "Project not set"

    **Problem**: `ERROR: (gcloud) You do not currently have an active project`

    **Solutions**:

    1. Set project in local config:
       ```bash
       gcloud config set project YOUR_PROJECT_ID
       ```

    2. Pass as environment variable:
       ```bash
       docker run --rm \
         -e CLOUDSDK_CORE_PROJECT=YOUR_PROJECT_ID \
         -v ~/.config/gcloud:/root/.config/gcloud \
         ghcr.io/jinalshah/devops/images/gcp-devops:latest \
         gcloud projects describe $CLOUDSDK_CORE_PROJECT
       ```

    3. Specify in command:
       ```bash
       docker run --rm \
         -v ~/.config/gcloud:/root/.config/gcloud \
         ghcr.io/jinalshah/devops/images/gcp-devops:latest \
         gcloud compute instances list --project=YOUR_PROJECT_ID
       ```

??? question "Permission denied on files"

    **Problem**: Cannot write files created by container

    **Solution**: Run with your user ID:

    ```bash
    docker run --rm \
      --user "$(id -u):$(id -g)" \  # (1)!
      -v $PWD:/workspace \
      -v ~/.config/gcloud:/root/.config/gcloud \
      -w /workspace \
      ghcr.io/jinalshah/devops/images/gcp-devops:latest \
      terraform fmt
    ```

    1. Use your local user/group ID to match file ownership

??? question "GKE credentials not working"

    **Problem**: Cannot connect to GKE cluster

    **Solutions**:

    1. Get fresh credentials:
       ```bash
       docker run --rm \
         -v ~/.config/gcloud:/root/.config/gcloud \
         -v ~/.kube:/root/.kube \
         ghcr.io/jinalshah/devops/images/gcp-devops:latest \
         gcloud container clusters get-credentials CLUSTER_NAME \
           --region REGION
       ```

    2. Verify kubeconfig:
       ```bash
       docker run --rm \
         -v ~/.kube:/root/.kube \
         ghcr.io/jinalshah/devops/images/gcp-devops:latest \
         kubectl config current-context
       ```

---

## Next Steps

- [Authentication Guide](authentication.md) - Detailed credential setup
- [Quick Reference](quick-reference.md) - Command cheat sheet
- [Docker Compose Examples](docker-compose.md) - Multi-container setups
- [Terraform Workflows](../workflows/terraform-workflows.md) - Advanced Terraform patterns
- [CI/CD Integration](../workflows/ci-cd-github.md) - Use in pipelines
