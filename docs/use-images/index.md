# Using the Images

This section covers pull, run, and automation patterns from beginner to advanced usage.

!!! tip "New to DevOps Images?"
    Start with the [Quick Start Guide](../quick-start.md) for a 5-minute introduction, or use the [Decision Framework](../choosing-an-image.md) to pick the right image for your needs.

## Pull an Image

Choose your preferred registry and image variant:

=== "all-devops (Multi-Cloud)"

    **Best for**: Teams using both AWS and GCP, or those who want maximum flexibility

    === "GHCR (Recommended)"

        ```bash
        docker pull ghcr.io/jinalshah/devops/images/all-devops:latest
        ```

        ✅ No rate limits | ✅ Fast global CDN | ✅ Best uptime

    === "GitLab Registry"

        ```bash
        docker pull registry.gitlab.com/jinal-shah/devops/images/all-devops:latest
        ```

        ✅ GitLab CI native | ✅ Private runner support

    === "Docker Hub"

        ```bash
        docker pull js01/all-devops:latest
        ```

        ⚠️  Rate limits: 100 pulls/6h (anonymous)

=== "aws-devops (AWS-Focused)"

    **Best for**: AWS-only teams who want a smaller image

    === "GHCR (Recommended)"

        ```bash
        docker pull ghcr.io/jinalshah/devops/images/aws-devops:latest
        ```

    === "GitLab Registry"

        ```bash
        docker pull registry.gitlab.com/jinal-shah/devops/images/aws-devops:latest
        ```

    === "Docker Hub"

        ```bash
        docker pull js01/aws-devops:latest
        ```

=== "gcp-devops (GCP-Focused)"

    **Best for**: GCP-only teams who want a smaller image

    === "GHCR (Recommended)"

        ```bash
        docker pull ghcr.io/jinalshah/devops/images/gcp-devops:latest
        ```

    === "GitLab Registry"

        ```bash
        docker pull registry.gitlab.com/jinal-shah/devops/images/gcp-devops:latest
        ```

    === "Docker Hub"

        ```bash
        docker pull js01/gcp-devops:latest
        ```

!!! warning "Docker Hub Rate Limits"
    Docker Hub enforces rate limits for anonymous users (100 pulls per 6 hours). We recommend using **GHCR** to avoid these limits.

## Run Interactively

Basic interactive run:

```bash
docker run -it --rm ghcr.io/jinalshah/devops/images/all-devops:latest
```

The default shell is `zsh` with Oh My Zsh pre-configured.

!!! tip "Shell Options"
    The image includes three shells:

    - **zsh** (default) - Modern shell with autocomplete and plugins
    - **bash** - Traditional Bourne Again Shell
    - **fish** - Friendly interactive shell

    Switch shells with: `bash`, `fish`, or `zsh`

## Recommended Workstation Setup

For real work, mount your credentials and project directory:

```bash
docker run -it --name devops-work \  # (1)!
  -v $PWD:/workspace \  # (2)!
  -v ~/.ssh:/root/.ssh \  # (3)!
  -v ~/.aws:/root/.aws \  # (4)!
  -v ~/.config/gcloud:/root/.config/gcloud \  # (5)!
  -v ~/.claude:/root/.claude \  # (6)!
  -v ~/.codex:/root/.codex \  # (7)!
  -v ~/.copilot:/root/.copilot \  # (8)!
  -v ~/.gemini:/root/.gemini \  # (9)!
  -w /workspace \  # (10)!
  ghcr.io/jinalshah/devops/images/all-devops:latest
```

1.  Named container for easy restart with `docker start -i devops-work`
2.  Mount current directory as `/workspace` for accessing your project files
3.  Mount SSH keys for Git operations and remote server access
4.  Mount AWS credentials for `aws` CLI (omit if not using AWS)
5.  Mount GCP credentials for `gcloud` (omit if not using GCP)
6.  Mount Claude AI credentials for `claude` CLI
7.  Mount Codex credentials for `codex` CLI (OpenAI)
8.  Mount Copilot credentials for `copilot` CLI (GitHub)
9.  Mount Gemini credentials for `gemini` CLI (Google)
10. Set working directory to `/workspace`

!!! info "Authentication Details"
    For comprehensive authentication setup including AI CLI configuration, see the [Authentication Guide](authentication.md).

## Run Tools Without an Interactive Shell

Execute single commands without entering a shell:

```bash
# Check tool versions
docker run --rm ghcr.io/jinalshah/devops/images/all-devops:latest terraform version
docker run --rm ghcr.io/jinalshah/devops/images/aws-devops:latest aws --version
docker run --rm ghcr.io/jinalshah/devops/images/gcp-devops:latest gcloud --version
docker run --rm ghcr.io/jinalshah/devops/images/all-devops:latest trivy --version
```

!!! example "One-Liner Examples"
    ```bash
    # Run Terraform plan
    docker run --rm -v $PWD:/workspace -w /workspace \
      ghcr.io/jinalshah/devops/images/all-devops:latest \
      terraform plan

    # Scan with Trivy
    docker run --rm -v $PWD:/workspace \
      ghcr.io/jinalshah/devops/images/all-devops:latest \
      trivy fs /workspace

    # Run Ansible playbook
    docker run --rm -v $PWD:/workspace -w /workspace \
      ghcr.io/jinalshah/devops/images/all-devops:latest \
      ansible-playbook site.yml
    ```

## Work With Local Files

Mount your project directory to access files:

```bash
docker run --rm \
  -v "$PWD:/workspace" \
  -w /workspace \
  ghcr.io/jinalshah/devops/images/all-devops:latest \
  ansible-playbook playbook.yml
```

### Avoid Root-Owned Files

To prevent Docker from creating root-owned files on your host:

```bash
docker run --rm \
  --user "$(id -u):$(id -g)" \
  -v "$PWD:/workspace" \
  -w /workspace \
  ghcr.io/jinalshah/devops/images/all-devops:latest \
  terraform fmt -recursive
```

!!! warning "User Flag Limitations"
    The `--user` flag may cause permission issues with some tools that expect to run as root. If you encounter errors, run without `--user` and manually fix permissions afterward:

    ```bash
    sudo chown -R $(id -u):$(id -g) .
    ```

## Quick Authentication Examples

Basic credential mounting for cloud providers and Git:

=== "AWS Authentication"

    ```bash
    docker run --rm \
      -v ~/.aws:/root/.aws \
      ghcr.io/jinalshah/devops/images/aws-devops:latest \
      aws sts get-caller-identity
    ```

=== "GCP Authentication"

    ```bash
    docker run --rm \
      -v ~/.config/gcloud:/root/.config/gcloud \
      ghcr.io/jinalshah/devops/images/gcp-devops:latest \
      gcloud auth list
    ```

=== "SSH for Git"

    ```bash
    docker run --rm \
      -v ~/.ssh:/root/.ssh \
      -v $PWD:/workspace \
      -w /workspace \
      ghcr.io/jinalshah/devops/images/all-devops:latest \
      git pull
    ```

!!! info "Comprehensive Authentication Guide"
    For detailed setup including AI CLI authentication, multiple cloud accounts, and troubleshooting, see the [Authentication Guide](authentication.md).

## Version Pinning for CI/CD

!!! tip "Use Immutable Tags in Production"
    Always pin specific image versions in CI/CD pipelines for reproducible builds:

    **✅ Good** - Immutable, predictable:
    ```bash
    docker pull ghcr.io/jinalshah/devops/images/all-devops:1.0.abc1234
    ```

    **⚠️  Avoid** - Mutable, can change:
    ```bash
    docker pull ghcr.io/jinalshah/devops/images/all-devops:latest
    ```

### Version Tag Format

- **`latest`** - Most recent build (for local development)
- **`1.0.abc1234`** - Semantic version + git commit SHA (for CI/CD)
- **`1.0`** - Semantic version only (semi-stable)

!!! example "Finding Available Tags"
    Check available tags on registries:

    - [GHCR Tags](https://github.com/jinalshah/devops-images/pkgs/container/devops%2Fimages%2Fall-devops)
    - [GitLab Tags](https://gitlab.com/jinal-shah/devops/container_registry)
    - [Docker Hub Tags](https://hub.docker.com/r/js01/all-devops/tags)

## CI/CD Integration Examples

### GitHub Actions

```yaml
name: Deploy Infrastructure

on:
  push:
    branches: [main]

jobs:
  deploy:
    runs-on: ubuntu-latest
    container:
      image: ghcr.io/jinalshah/devops/images/all-devops:1.0.abc1234  # (1)!

    steps:
      - uses: actions/checkout@v4

      - name: Configure AWS Credentials
        uses: aws-actions/configure-aws-credentials@v4
        with:
          aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
          aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
          aws-region: us-east-1

      - name: Deploy with Terraform
        run: |
          terraform init
          terraform apply -auto-approve
```

1.  Pin to specific version for reproducible builds

### GitLab CI

```yaml
stages:
  - deploy

deploy:production:
  stage: deploy
  image: registry.gitlab.com/jinal-shah/devops/images/all-devops:1.0.abc1234
  script:
    - terraform init
    - terraform apply -auto-approve
  variables:
    AWS_ACCESS_KEY_ID: $AWS_ACCESS_KEY_ID
    AWS_SECRET_ACCESS_KEY: $AWS_SECRET_ACCESS_KEY
    AWS_DEFAULT_REGION: us-east-1
  only:
    - main
```

!!! info "More CI/CD Examples"
    For comprehensive CI/CD integration guides, see:

    - [GitHub Actions Examples](../workflows/ci-cd-github.md)
    - [GitLab CI Examples](../workflows/ci-cd-gitlab.md)
    - [Jenkins Examples](../workflows/ci-cd-jenkins.md)
    - [CircleCI Examples](../workflows/ci-cd-circleci.md)

## Next Steps

**Getting Started**:

- [Quick Start Guide](../quick-start.md) - 5-minute introduction
- [Authentication Setup](authentication.md) - Configure credentials
- [Quick Reference](quick-reference.md) - Common command patterns

**Cloud-Specific Guides**:

- [Using all-devops](all-devops.md) - Multi-cloud image
- [Using aws-devops](aws-devops.md) - AWS-focused image
- [Using gcp-devops](gcp-devops.md) - GCP-focused image

**Advanced Topics**:

- [Docker Compose Examples](docker-compose.md) - Multi-container setups
- [Workflows & Patterns](../workflows/index.md) - Real-world examples
- [Troubleshooting](../troubleshooting/index.md) - Common issues
