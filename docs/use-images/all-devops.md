# All DevOps Image

The **all-devops** image is the complete multi-cloud toolkit with both AWS and GCP tools, providing maximum flexibility for teams working across cloud providers.

!!! info "Image Details"
    **Size**: ~3.2 GB | **Architectures**: amd64, arm64 | **Base**: Rocky Linux 9

## When to Use This Image

✅ **Perfect for**:

- Platform teams managing multi-cloud infrastructure (AWS + GCP)
- Organisations with a hybrid cloud strategy
- CI/CD pipelines deploying to multiple cloud providers
- Development teams who need maximum flexibility
- Exploring both AWS and GCP tools without switching images

⚠️  **Consider alternatives if**:

- You only use AWS → Use [aws-devops](aws-devops.md) to save ~400 MB
- You only use GCP → Use [gcp-devops](gcp-devops.md) to save ~300 MB
- Image size is critical → See [optimisation guide](../build-images/optimisation.md)

## Pull the Image

=== "GHCR (Recommended)"

    ```bash
    # Latest version
    docker pull ghcr.io/jinalshah/devops/images/all-devops:latest

    # Pinned version (recommended for CI/CD)
    docker pull ghcr.io/jinalshah/devops/images/all-devops:1.0.abc1234
    ```

    ✅ No rate limits | ✅ Fast CDN | ✅ Best uptime

=== "GitLab Registry"

    ```bash
    # Latest version
    docker pull registry.gitlab.com/jinal-shah/devops/images/all-devops:latest

    # Pinned version
    docker pull registry.gitlab.com/jinal-shah/devops/images/all-devops:1.0.abc1234
    ```

    ✅ Native GitLab CI integration

=== "Docker Hub"

    ```bash
    # Latest version
    docker pull js01/all-devops:latest

    # Pinned version
    docker pull js01/all-devops:1.0.abc1234
    ```

    ⚠️  Rate limits apply (100 pulls/6h for anonymous users)

## What's Included

### Infrastructure as Code

| Tool | Version | Purpose |
|------|---------|---------|
| **Terraform** | Multi-version via tfswitch | Infrastructure provisioning |
| **Terragrunt** | Latest | DRY Terraform configurations |
| **TFLint** | Latest | Terraform linting |
| **Packer** | Latest | Image building |

### Kubernetes & Containers

| Tool | Version | Purpose |
|------|---------|---------|
| **kubectl** | Latest | Kubernetes management |
| **Helm 3** | Latest | Kubernetes package manager |
| **k9s** | Latest | Kubernetes terminal UI |

### AWS Tools ☁️

| Tool | Purpose |
|------|---------|
| **AWS CLI v2** | AWS service management |
| **Session Manager Plugin** | EC2 instance access without SSH |
| **boto3** | AWS SDK for Python |
| **cfn-lint** | CloudFormation linting |
| **s3cmd** | S3 operations |

### GCP Tools ☁️

| Tool | Purpose |
|------|---------|
| **gcloud** | GCP service management |
| **docker-credential-gcr** | GCR authentication |
| **gsutil** | Cloud Storage operations (via gcloud) |

### Configuration & Security

| Tool | Purpose |
|------|---------|
| **Ansible** | Configuration management |
| **ansible-lint** | Playbook validation |
| **Trivy** | Vulnerability scanning |
| **pre-commit** | Git hook framework |
| **Task** | Modern task runner |

### AI-Powered Development

| Tool | Provider | Best For |
|------|----------|----------|
| **claude** | Anthropic | Code review, architecture |
| **codex** | OpenAI | Code generation |
| **copilot** | GitHub | IDE integration |
| **gemini** | Google | Multi-modal, GCP tasks |

See [AI CLI Setup Guide](../tool-basics/ai-cli-setup.md) for authentication and usage.

### Development Tools

| Tool | Version |
|------|---------|
| **Python** | 3.12 |
| **Node.js** | LTS |
| **Git** | Latest |
| **GitHub CLI (gh)** | Latest |
| **jq** | Latest |

### Database Clients

| Tool | Version |
|------|---------|
| **mongosh** | v6.0 |
| **psql** | PostgreSQL 17 |
| **mysql** | Latest |

### Network & Utilities

- **dig, nslookup** - DNS troubleshooting
- **ncat, telnet** - Network connectivity
- **curl, wget** - HTTP clients
- **vim, less** - Editors/pagers
- **tree** - Directory visualisation

## Quick Start

### Interactive Shell

```bash
docker run -it --rm \
  -v $PWD:/workspace \
  -v ~/.aws:/root/.aws \
  -v ~/.config/gcloud:/root/.config/gcloud \
  -v ~/.ssh:/root/.ssh \
  -w /workspace \
  ghcr.io/jinalshah/devops/images/all-devops:latest
```

### One-Liner Commands

```bash
# Check versions
docker run --rm ghcr.io/jinalshah/devops/images/all-devops:latest terraform version
docker run --rm ghcr.io/jinalshah/devops/images/all-devops:latest aws --version
docker run --rm ghcr.io/jinalshah/devops/images/all-devops:latest gcloud --version

# Verify authentication
docker run --rm -v ~/.aws:/root/.aws \
  ghcr.io/jinalshah/devops/images/all-devops:latest \
  aws sts get-caller-identity

docker run --rm -v ~/.config/gcloud:/root/.config/gcloud \
  ghcr.io/jinalshah/devops/images/all-devops:latest \
  gcloud auth list
```

## Real-World Examples

### Multi-Cloud Terraform Deployment

Deploy infrastructure to both AWS and GCP:

```bash
docker run --rm \
  -v $PWD:/workspace \
  -v ~/.aws:/root/.aws \
  -v ~/.config/gcloud:/root/.config/gcloud \
  -w /workspace \
  ghcr.io/jinalshah/devops/images/all-devops:latest \
  sh -c "
    # Deploy AWS infrastructure
    cd aws/
    terraform init
    terraform apply -auto-approve

    # Deploy GCP infrastructure
    cd ../gcp/
    terraform init
    terraform apply -auto-approve
  "
```

### Multi-Cloud Kubernetes Deployment

Deploy to both EKS and GKE:

```bash
docker run --rm \
  -v $PWD:/workspace \
  -v ~/.aws:/root/.aws \
  -v ~/.config/gcloud:/root/.config/gcloud \
  -v ~/.kube:/root/.kube \
  -w /workspace \
  ghcr.io/jinalshah/devops/images/all-devops:latest \
  sh -c "
    # Deploy to EKS
    aws eks update-kubeconfig --region us-east-1 --name my-eks-cluster
    helm upgrade --install myapp ./charts/myapp --namespace production

    # Deploy to GKE
    gcloud container clusters get-credentials my-gke-cluster --region us-central1
    helm upgrade --install myapp ./charts/myapp --namespace production
  "
```

### Security Scanning Across Cloud Configs

```bash
docker run --rm -v $PWD:/workspace -w /workspace \
  ghcr.io/jinalshah/devops/images/all-devops:latest \
  sh -c "
    # Scan Terraform configs
    trivy config ./terraform/aws
    trivy config ./terraform/gcp

    # Lint CloudFormation
    cfn-lint ./cloudformation/**/*.yaml

    # Validate Terraform
    cd terraform/aws && terraform validate
    cd ../gcp && terraform validate
  "
```

## CI/CD Integration

### GitHub Actions

```yaml
name: Multi-Cloud Deploy

on:
  push:
    branches: [main]

jobs:
  deploy:
    runs-on: ubuntu-latest
    container:
      image: ghcr.io/jinalshah/devops/images/all-devops:1.0.abc1234

    steps:
      - uses: actions/checkout@v4

      - name: Configure AWS
        uses: aws-actions/configure-aws-credentials@v4
        with:
          aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
          aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
          aws-region: us-east-1

      - name: Configure GCP
        uses: google-github-actions/auth@v2
        with:
          credentials_json: ${{ secrets.GCP_SA_KEY }}

      - name: Deploy to AWS
        run: |
          cd terraform/aws
          terraform init
          terraform apply -auto-approve

      - name: Deploy to GCP
        run: |
          cd terraform/gcp
          terraform init
          terraform apply -auto-approve
```

### GitLab CI

```yaml
stages:
  - deploy

deploy:multi-cloud:
  stage: deploy
  image: registry.gitlab.com/jinal-shah/devops/images/all-devops:1.0.abc1234
  script:
    # AWS deployment
    - cd terraform/aws
    - terraform init
    - terraform apply -auto-approve
    # GCP deployment
    - cd ../gcp
    - terraform init
    - terraform apply -auto-approve
  variables:
    AWS_ACCESS_KEY_ID: $AWS_ACCESS_KEY_ID
    AWS_SECRET_ACCESS_KEY: $AWS_SECRET_ACCESS_KEY
    GOOGLE_APPLICATION_CREDENTIALS: /tmp/gcp-key.json
  before_script:
    - echo $GCP_SA_KEY | base64 -d > /tmp/gcp-key.json
  only:
    - main
```

## Troubleshooting

??? question "AWS commands failing with 'Unable to locate credentials'"

    **Problem**: AWS CLI can't find credentials

    **Solution**: Ensure ~/.aws is mounted correctly
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

??? question "gcloud commands failing with authentication errors"

    **Problem**: GCP CLI can't authenticate

    **Solution**: Run gcloud auth on host first
    ```bash
    # On host machine
    gcloud auth login
    gcloud auth application-default login

    # Then use in container
    docker run --rm \
      -v ~/.config/gcloud:/root/.config/gcloud \
      ghcr.io/jinalshah/devops/images/all-devops:latest \
      gcloud auth list
    ```

??? question "Image pull is slow"

    **Problem**: Large image size (~3.2 GB)

    **Solutions**:

    1. Use GHCR instead of Docker Hub (faster CDN)
    2. Consider using [aws-devops](aws-devops.md) or [gcp-devops](gcp-devops.md) if you only need one cloud
    3. Pre-pull images in CI/CD setup phase
    4. Use pinned versions to leverage Docker layer caching

## Performance Tips

!!! tip "Optimise for CI/CD"

    1. **Pin versions**: Use immutable tags like `1.0.abc1234` instead of `latest`
    2. **Pre-pull images**: Pull during CI setup phase, not during actual work
    3. **Layer caching**: Use consistent image versions across pipeline jobs
    4. **Registry choice**: GHCR has the best performance for most regions

!!! tip "Reduce Local Disk Usage"

    ```bash
    # Remove old images
    docker image prune -a

    # Or use smaller cloud-specific images
    docker pull ghcr.io/jinalshah/devops/images/aws-devops:latest  # ~400 MB smaller
    ```

## Next Steps

- [Authentication Guide](authentication.md) - Set up AWS, GCP, and AI CLI credentials
- [Workflows](../workflows/index.md) - Multi-cloud workflow patterns
- [Architecture](../architecture/index.md) - Understand what's inside
- [Choosing an Image](../choosing-an-image.md) - Compare all variants
