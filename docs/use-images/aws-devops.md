# AWS DevOps Image

AWS-optimized container with all essential DevOps tools plus AWS-specific CLIs and libraries. Perfect for AWS-centric workflows while maintaining full platform tool support.

---

## Pull the Image

=== "GHCR (Recommended)"

    ```bash
    # Latest version
    docker pull ghcr.io/jinalshah/devops/images/aws-devops:latest

    # Specific version (recommended for CI/CD)
    docker pull ghcr.io/jinalshah/devops/images/aws-devops:1.0.abc1234
    ```

    !!! tip "Why GHCR?"
        - **No rate limits** for public images
        - **Built-in GitHub integration** for CI/CD
        - **Faster pulls** from GitHub Actions

=== "GitLab Registry"

    ```bash
    # Latest version
    docker pull registry.gitlab.com/jinal-shah/devops/images/aws-devops:latest

    # Specific version
    docker pull registry.gitlab.com/jinal-shah/devops/images/aws-devops:1.0.abc1234
    ```

    !!! tip "When to use"
        - Using GitLab CI/CD pipelines
        - Need GitLab Container Registry integration
        - Already authenticated with GitLab

=== "Docker Hub"

    ```bash
    # Latest version
    docker pull js01/aws-devops:latest

    # Specific version
    docker pull js01/aws-devops:1.0.abc1234
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

### AWS-Specific Additions

Tools optimized for AWS workflows:

- **AWS CLI v2**: Latest AWS command-line interface
- **AWS Session Manager Plugin**: Direct SSH-like access to EC2 instances
- **Python Libraries**:
  - `boto3`: AWS SDK for Python automation
  - `cfn-lint`: CloudFormation template validation
  - `s3cmd`: Advanced S3 operations
  - `crcmod`: CRC32c verification for uploads

---

## Quick Start

### Interactive Shell

```bash
# Basic interactive shell with AWS credentials
docker run -it --rm \
  -v $PWD:/workspace \  # (1)!
  -v ~/.aws:/root/.aws \  # (2)!
  -w /workspace \  # (3)!
  ghcr.io/jinalshah/devops/images/aws-devops:latest
```

1. Mount current directory to `/workspace` for file access
2. Mount AWS credentials for authentication
3. Set working directory to your project

### One-Off Commands

=== "AWS CLI"

    ```bash
    # Verify AWS identity
    docker run --rm \
      -v ~/.aws:/root/.aws \
      ghcr.io/jinalshah/devops/images/aws-devops:latest \
      aws sts get-caller-identity

    # List S3 buckets
    docker run --rm \
      -v ~/.aws:/root/.aws \
      ghcr.io/jinalshah/devops/images/aws-devops:latest \
      aws s3 ls
    ```

=== "Terraform + AWS"

    ```bash
    # Terraform plan with AWS credentials
    docker run --rm \
      -v $PWD:/workspace \
      -v ~/.aws:/root/.aws \
      -w /workspace \
      ghcr.io/jinalshah/devops/images/aws-devops:latest \
      terraform plan

    # Terraform apply
    docker run --rm \
      -v $PWD:/workspace \
      -v ~/.aws:/root/.aws \
      -w /workspace \
      ghcr.io/jinalshah/devops/images/aws-devops:latest \
      terraform apply -auto-approve
    ```

=== "CloudFormation"

    ```bash
    # Validate CloudFormation template
    docker run --rm \
      -v $PWD:/workspace \
      -w /workspace \
      ghcr.io/jinalshah/devops/images/aws-devops:latest \
      cfn-lint template.yaml

    # Deploy stack
    docker run --rm \
      -v $PWD:/workspace \
      -v ~/.aws:/root/.aws \
      -w /workspace \
      ghcr.io/jinalshah/devops/images/aws-devops:latest \
      aws cloudformation deploy \
        --template-file template.yaml \
        --stack-name my-stack
    ```

=== "Python + Boto3"

    ```bash
    # Run Python script with boto3
    docker run --rm \
      -v $PWD:/workspace \
      -v ~/.aws:/root/.aws \
      -w /workspace \
      ghcr.io/jinalshah/devops/images/aws-devops:latest \
      python3 aws-automation.py
    ```

---

## Authentication Methods

### Method 1: Mount AWS Credentials (Recommended)

```bash
docker run -it --rm \
  -v ~/.aws:/root/.aws \  # (1)!
  ghcr.io/jinalshah/devops/images/aws-devops:latest \
  aws sts get-caller-identity
```

1. Mounts your local `~/.aws` directory containing `credentials` and `config` files

**Files mounted**:
- `~/.aws/credentials` - AWS access keys
- `~/.aws/config` - AWS CLI configuration (regions, output format)

### Method 2: Environment Variables

```bash
docker run -it --rm \
  -e AWS_ACCESS_KEY_ID=AKIAIOSFODNN7EXAMPLE \  # (1)!
  -e AWS_SECRET_ACCESS_KEY=wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY \  # (2)!
  -e AWS_DEFAULT_REGION=us-east-1 \  # (3)!
  ghcr.io/jinalshah/devops/images/aws-devops:latest \
  aws s3 ls
```

1. Your AWS access key ID
2. Your AWS secret access key
3. Default AWS region for operations

!!! warning "Security"
    Environment variables are visible in `docker inspect` output. For production, prefer mounting credentials or using IAM roles.

### Method 3: IAM Role (ECS/EC2)

When running on AWS infrastructure (ECS, EC2, EKS), the container automatically inherits IAM credentials:

```bash
# No credentials needed - uses instance/task role
docker run -it --rm \
  ghcr.io/jinalshah/devops/images/aws-devops:latest \
  aws sts get-caller-identity
```

**Supported AWS environments**:
- ECS tasks with task roles
- EC2 instances with instance profiles
- EKS pods with IRSA (IAM Roles for Service Accounts)

---

## Common Workflows

### Terraform on AWS

```bash
#!/bin/bash
# Deploy infrastructure to AWS

docker run --rm \
  -v $PWD:/workspace \
  -v ~/.aws:/root/.aws \
  -w /workspace \
  ghcr.io/jinalshah/devops/images/aws-devops:latest \
  sh -c "
    terraform init
    terraform validate
    terraform plan -out=tfplan
    terraform apply tfplan
  "
```

### Ansible with EC2 Dynamic Inventory

```bash
# Run playbook against EC2 instances
docker run --rm \
  -v $PWD:/workspace \
  -v ~/.aws:/root/.aws \
  -v ~/.ssh:/root/.ssh \  # (1)!
  -w /workspace \
  ghcr.io/jinalshah/devops/images/aws-devops:latest \
  ansible-playbook \
    -i aws_ec2.yml \  # (2)!
    deploy.yml
```

1. Mount SSH keys for EC2 instance access
2. AWS EC2 dynamic inventory plugin

### Security Scanning

```bash
# Scan CloudFormation templates
docker run --rm \
  -v $PWD:/workspace \
  -w /workspace \
  ghcr.io/jinalshah/devops/images/aws-devops:latest \
  sh -c "
    cfn-lint cloudformation/**/*.yaml
    trivy config cloudformation/
  "
```

### Python Automation with Boto3

```bash
# Run AWS automation script
docker run --rm \
  -v $PWD:/workspace \
  -v ~/.aws:/root/.aws \
  -w /workspace \
  ghcr.io/jinalshah/devops/images/aws-devops:latest \
  python3 scripts/cleanup-unused-ebs.py
```

---

## Best Use Cases

!!! success "Perfect For"

    - ✅ **AWS-first DevOps teams**: No GCP tools to reduce image size
    - ✅ **AWS-only CI/CD pipelines**: Faster startup than multi-cloud image
    - ✅ **CloudFormation workflows**: Built-in `cfn-lint` validation
    - ✅ **Terraform on AWS**: Full Terraform + AWS CLI integration
    - ✅ **Python automation**: Pre-installed boto3 and AWS libraries
    - ✅ **EKS deployments**: kubectl + Helm + AWS CLI in one image

!!! info "Consider all-devops if you need"

    - Multi-cloud (AWS + GCP) support
    - `gcloud` CLI for hybrid workflows
    - Team works across cloud providers

---

## Image Size

| Image | Size | AWS Tools |
|-------|------|-----------|
| **aws-devops** | ~2.8 GB | AWS CLI, boto3, cfn-lint, Session Manager |
| all-devops | ~3.2 GB | AWS + GCP tools |

**Size savings**: ~400 MB compared to `all-devops` by excluding GCP-specific tools.

---

## Dockerfile Reference

Want to build your own? See [Building AWS DevOps Image](../build-images/aws-devops.md) for:

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
      -v ~/.aws:/root/.aws \
      -v ~/.terraform.d:/root/.terraform.d \  # (1)!
      -w /workspace \
      ghcr.io/jinalshah/devops/images/aws-devops:latest \
      terraform init
    ```

    1. Cache Terraform plugins across runs (saves download time)

??? tip "Named Container for Persistent Shell"

    Keep a persistent container for ongoing work:

    ```bash
    # Create named container
    docker run -it --name aws-dev \
      -v $PWD:/workspace \
      -v ~/.aws:/root/.aws \
      -w /workspace \
      ghcr.io/jinalshah/devops/images/aws-devops:latest

    # Later, restart the same container
    docker start -i aws-dev
    ```

??? tip "Custom Shell Alias"

    Add to `~/.bashrc` or `~/.zshrc`:

    ```bash
    alias aws-devops='docker run -it --rm \
      -v $PWD:/workspace \
      -v ~/.aws:/root/.aws \
      -v ~/.ssh:/root/.ssh \
      -w /workspace \
      ghcr.io/jinalshah/devops/images/aws-devops:latest'

    # Usage
    aws-devops terraform plan
    aws-devops aws s3 ls
    ```

---

## Troubleshooting

??? question "AWS credentials not found"

    **Problem**: `Unable to locate credentials`

    **Solutions**:

    1. Verify credentials exist locally:
       ```bash
       cat ~/.aws/credentials
       ```

    2. Check mount is working:
       ```bash
       docker run --rm -v ~/.aws:/root/.aws \
         ghcr.io/jinalshah/devops/images/aws-devops:latest \
         ls -la /root/.aws
       ```

    3. Use environment variables instead:
       ```bash
       docker run --rm \
         -e AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID \
         -e AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY \
         ghcr.io/jinalshah/devops/images/aws-devops:latest \
         aws sts get-caller-identity
       ```

??? question "Region errors"

    **Problem**: `You must specify a region`

    **Solutions**:

    1. Set default region in `~/.aws/config`:
       ```ini
       [default]
       region = us-east-1
       ```

    2. Pass as environment variable:
       ```bash
       docker run --rm \
         -e AWS_DEFAULT_REGION=us-east-1 \
         -v ~/.aws:/root/.aws \
         ghcr.io/jinalshah/devops/images/aws-devops:latest \
         aws s3 ls
       ```

??? question "Permission denied on files"

    **Problem**: Cannot write files created by container

    **Solution**: Run with your user ID:

    ```bash
    docker run --rm \
      --user "$(id -u):$(id -g)" \  # (1)!
      -v $PWD:/workspace \
      -v ~/.aws:/root/.aws \
      -w /workspace \
      ghcr.io/jinalshah/devops/images/aws-devops:latest \
      terraform fmt
    ```

    1. Use your local user/group ID to match file ownership

---

## Next Steps

- [Authentication Guide](authentication.md) - Detailed credential setup
- [Quick Reference](quick-reference.md) - Command cheat sheet
- [Docker Compose Examples](docker-compose.md) - Multi-container setups
- [Terraform Workflows](../workflows/terraform-workflows.md) - Advanced Terraform patterns
- [CI/CD Integration](../workflows/ci-cd-github.md) - Use in pipelines
