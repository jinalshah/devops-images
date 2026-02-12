# Authentication & Credentials

Learn how to securely configure cloud provider credentials, SSH keys, and AI CLI authentication when using DevOps Images.

## Volume Mount Strategy

The DevOps Images use volume mounts to access your credentials from the host machine, ensuring secrets never get baked into the container image.

```mermaid
graph TB
    HOST[Host Machine] --> MOUNTS[Volume Mounts]

    subgraph "Host Credentials"
        AWS_H[~/.aws]
        GCP_H[~/.config/gcloud]
        SSH_H[~/.ssh]
        CLAUDE_H[~/.claude]
        CODEX_H[~/.codex]
        COPILOT_H[~/.copilot]
        GEMINI_H[~/.gemini]
    end

    subgraph "Container Paths"
        AWS_C[/root/.aws]
        GCP_C[/root/.config/gcloud]
        SSH_C[/root/.ssh]
        CLAUDE_C[/root/.claude]
        CODEX_C[/root/.codex]
        COPILOT_C[/root/.copilot]
        GEMINI_C[/root/.gemini]
    end

    AWS_H -.->|-v ~/.aws:/root/.aws| AWS_C
    GCP_H -.->|-v ~/.config/gcloud:/root/.config/gcloud| GCP_C
    SSH_H -.->|-v ~/.ssh:/root/.ssh| SSH_C
    CLAUDE_H -.->|-v ~/.claude:/root/.claude| CLAUDE_C
    CODEX_H -.->|-v ~/.codex:/root/.codex| CODEX_C
    COPILOT_H -.->|-v ~/.copilot:/root/.copilot| COPILOT_C
    GEMINI_H -.->|-v ~/.gemini:/root/.gemini| GEMINI_C

    subgraph "Available Tools"
        AWS_CLI[aws cli]
        GCLOUD[gcloud]
        GIT[git]
        CLAUDE_CLI[claude]
        CODEX_CLI[codex]
        COPILOT_CLI[copilot]
        GEMINI_CLI[gemini]
    end

    AWS_C --> AWS_CLI
    GCP_C --> GCLOUD
    SSH_C --> GIT
    CLAUDE_C --> CLAUDE_CLI
    CODEX_C --> CODEX_CLI
    COPILOT_C --> COPILOT_CLI
    GEMINI_C --> GEMINI_CLI

    style HOST fill:#4A90E2,color:#fff
    style AWS_CLI fill:#FF9F43,color:#fff
    style GCLOUD fill:#5F8D4E,color:#fff
```

## Complete Docker Run Command

```bash
docker run -it --rm \
  --name devops-work \
  -v $PWD:/workspace \
  -v ~/.aws:/root/.aws \
  -v ~/.config/gcloud:/root/.config/gcloud \
  -v ~/.ssh:/root/.ssh \
  -v ~/.claude:/root/.claude \
  -v ~/.codex:/root/.codex \
  -v ~/.copilot:/root/.copilot \
  -v ~/.gemini:/root/.gemini \
  -w /workspace \
  ghcr.io/jinalshah/devops/images/all-devops:latest
```

!!! tip "Code Annotation"
    Hover over the numbers for explanations of each mount:

```bash
docker run -it --rm \
  -v $PWD:/workspace \  # (1)!
  -v ~/.aws:/root/.aws \  # (2)!
  -v ~/.config/gcloud:/root/.config/gcloud \  # (3)!
  -v ~/.ssh:/root/.ssh \  # (4)!
  -v ~/.claude:/root/.claude \  # (5)!
  -v ~/.codex:/root/.codex \  # (6)!
  -v ~/.copilot:/root/.copilot \  # (7)!
  -v ~/.gemini:/root/.gemini \  # (8)!
  -w /workspace \  # (9)!
  ghcr.io/jinalshah/devops/images/all-devops:latest
```

1.  Mount current directory to `/workspace` for accessing your project files
2.  Mount AWS credentials for `aws` CLI authentication
3.  Mount GCP credentials for `gcloud` authentication
4.  Mount SSH keys for Git operations and remote server access
5.  Mount Claude AI credentials for `claude` CLI
6.  Mount Codex credentials for OpenAI `codex` CLI
7.  Mount Copilot credentials for GitHub `copilot` CLI
8.  Mount Gemini credentials for Google `gemini` CLI
9.  Set working directory to `/workspace` so you start in your project

## AWS Authentication

The DevOps Images support multiple AWS authentication methods.

=== "IAM User (Access Keys)"

    ### Setup

    ```bash
    # On host machine
    aws configure
    ```

    This creates `~/.aws/credentials` and `~/.aws/config`.

    ### Usage

    ```bash
    docker run --rm \
      -v ~/.aws:/root/.aws \
      ghcr.io/jinalshah/devops/images/aws-devops:latest \
      aws sts get-caller-identity
    ```

    ### Credentials File

    ```ini
    # ~/.aws/credentials
    [default]
    aws_access_key_id = AKIAIOSFODNN7EXAMPLE
    aws_secret_access_key = wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY

    [staging]
    aws_access_key_id = AKIAI44QH8DHBEXAMPLE
    aws_secret_access_key = je7MtGbClwBF/2Zp9Utk/h3yCo8nvbEXAMPLEKEY
    ```

    ```ini
    # ~/.aws/config
    [default]
    region = us-east-1
    output = json

    [profile staging]
    region = us-west-2
    output = json
    ```

=== "IAM Role (EC2/ECS)"

    ### For EC2 Instances

    No credentials needed! The instance role is automatically detected.

    ```bash
    # Run on EC2 instance with IAM role attached
    docker run --rm \
      ghcr.io/jinalshah/devops/images/aws-devops:latest \
      aws sts get-caller-identity
    ```

    ### For ECS Tasks

    ```json
    {
      "taskRoleArn": "arn:aws:iam::123456789012:role/ecsTaskRole",
      "containerDefinitions": [{
        "name": "devops",
        "image": "ghcr.io/jinalshah/devops/images/aws-devops:latest",
        "command": ["terraform", "apply", "-auto-approve"]
      }]
    }
    ```

=== "SSO (AWS IAM Identity Centre)"

    ### Setup

    ```bash
    # On host machine
    aws configure sso
    # Follow prompts to set up SSO

    # Login
    aws sso login --profile my-sso-profile
    ```

    ### Usage

    ```bash
    docker run --rm \
      -v ~/.aws:/root/.aws \
      -e AWS_PROFILE=my-sso-profile \
      ghcr.io/jinalshah/devops/images/aws-devops:latest \
      aws sts get-caller-identity
    ```

=== "Environment Variables"

    ### Usage

    ```bash
    docker run --rm \
      -e AWS_ACCESS_KEY_ID=AKIAIOSFODNN7EXAMPLE \
      -e AWS_SECRET_ACCESS_KEY=wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY \
      -e AWS_DEFAULT_REGION=us-east-1 \
      ghcr.io/jinalshah/devops/images/aws-devops:latest \
      aws sts get-caller-identity
    ```

    !!! warning "Security Warning"
        Avoid using environment variables for credentials in shared environments. Prefer volume mounts or IAM roles.

### Using Multiple AWS Profiles

```bash
# Set profile via environment variable
docker run --rm \
  -v ~/.aws:/root/.aws \
  -e AWS_PROFILE=staging \
  ghcr.io/jinalshah/devops/images/aws-devops:latest \
  aws sts get-caller-identity

# Or use --profile flag
docker run --rm \
  -v ~/.aws:/root/.aws \
  ghcr.io/jinalshah/devops/images/aws-devops:latest \
  aws --profile staging sts get-caller-identity
```

### AWS Session Manager

For EC2 instance access using Session Manager:

```bash
# Connect to instance
docker run -it --rm \
  -v ~/.aws:/root/.aws \
  ghcr.io/jinalshah/devops/images/aws-devops:latest \
  aws ssm start-session --target i-1234567890abcdef0

# Port forwarding
docker run -it --rm \
  -v ~/.aws:/root/.aws \
  -p 8080:8080 \
  ghcr.io/jinalshah/devops/images/aws-devops:latest \
  aws ssm start-session --target i-1234567890abcdef0 \
    --document-name AWS-StartPortForwardingSession \
    --parameters '{"portNumber":["8080"],"localPortNumber":["8080"]}'
```

---

## GCP Authentication

The DevOps Images support multiple GCP authentication methods.

=== "Service Account Key"

    ### Setup

    ```bash
    # On host machine - download service account key
    export GOOGLE_APPLICATION_CREDENTIALS=~/gcp-key.json

    # Authenticate gcloud
    gcloud auth activate-service-account --key-file=~/gcp-key.json
    ```

    ### Usage

    ```bash
    docker run --rm \
      -v ~/.config/gcloud:/root/.config/gcloud \
      -v ~/gcp-key.json:/root/gcp-key.json \
      -e GOOGLE_APPLICATION_CREDENTIALS=/root/gcp-key.json \
      ghcr.io/jinalshah/devops/images/gcp-devops:latest \
      gcloud auth list
    ```

=== "gcloud auth login"

    ### Setup

    ```bash
    # On host machine - interactive login
    gcloud auth login
    gcloud config set project my-project-id
    ```

    ### Usage

    ```bash
    docker run --rm \
      -v ~/.config/gcloud:/root/.config/gcloud \
      ghcr.io/jinalshah/devops/images/gcp-devops:latest \
      gcloud auth list
    ```

=== "Application Default Credentials"

    ### Setup

    ```bash
    # On host machine
    gcloud auth application-default login
    ```

    ### Usage

    ```bash
    docker run --rm \
      -v ~/.config/gcloud:/root/.config/gcloud \
      ghcr.io/jinalshah/devops/images/gcp-devops:latest \
      gcloud auth application-default print-access-token
    ```

=== "Workload Identity (GKE)"

    ### For GKE Pods

    No credentials needed! Workload Identity is automatically configured.

    ```yaml
    apiVersion: v1
    kind: Pod
    metadata:
      name: devops-pod
    spec:
      serviceAccountName: my-ksa
      containers:
      - name: devops
        image: ghcr.io/jinalshah/devops/images/gcp-devops:latest
        command: ["gcloud", "auth", "list"]
    ```

### GCP Multiple Projects

```bash
# Set active project
docker run --rm \
  -v ~/.config/gcloud:/root/.config/gcloud \
  ghcr.io/jinalshah/devops/images/gcp-devops:latest \
  gcloud config set project my-project-id

# Or use --project flag
docker run --rm \
  -v ~/.config/gcloud:/root/.config/gcloud \
  ghcr.io/jinalshah/devops/images/gcp-devops:latest \
  gcloud compute instances list --project my-project-id
```

---

## SSH Key Authentication

For Git operations and remote server access.

### Setup

```bash
# Use your existing SSH keys
docker run -it --rm \
  -v ~/.ssh:/root/.ssh \
  ghcr.io/jinalshah/devops/images/all-devops:latest \
  ssh-add -l
```

### Git Over SSH

```bash
docker run -it --rm \
  -v $PWD:/workspace \
  -v ~/.ssh:/root/.ssh \
  -w /workspace \
  ghcr.io/jinalshah/devops/images/all-devops:latest \
  git clone git@github.com:yourusername/your-repo.git
```

### SSH to Remote Servers

```bash
docker run -it --rm \
  -v ~/.ssh:/root/.ssh \
  ghcr.io/jinalshah/devops/images/all-devops:latest \
  ssh user@remote-server.com
```

!!! tip "SSH Agent Forwarding"
    For SSH agent forwarding on macOS/Linux:

    ```bash
    docker run -it --rm \
      -v $SSH_AUTH_SOCK:/ssh-agent \
      -e SSH_AUTH_SOCK=/ssh-agent \
      -v ~/.ssh:/root/.ssh \
      ghcr.io/jinalshah/devops/images/all-devops:latest \
      ssh user@remote-server.com
    ```

---

## AI CLI Authentication

All DevOps Images include four AI CLI tools. Each requires separate authentication.

### Claude CLI (Anthropic)

**Setup**: Interactive authentication

```bash
docker run -it --rm \
  -v ~/.claude:/root/.claude \
  ghcr.io/jinalshah/devops/images/all-devops:latest \
  claude auth login
```

Follow the prompts to authenticate with your Anthropic account.

**Usage**:

```bash
docker run --rm \
  -v $PWD:/workspace \
  -v ~/.claude:/root/.claude \
  -w /workspace \
  ghcr.io/jinalshah/devops/images/all-devops:latest \
  claude "Review this Terraform code" --file main.tf
```

**Verification**:

```bash
docker run --rm \
  -v ~/.claude:/root/.claude \
  ghcr.io/jinalshah/devops/images/all-devops:latest \
  claude --version
```

### Codex CLI (OpenAI)

**Setup**: API key configuration

```bash
# Set API key as environment variable
export OPENAI_API_KEY="sk-..."

# Or create config file
mkdir -p ~/.codex
echo "OPENAI_API_KEY=sk-..." > ~/.codex/config
```

**Usage**:

```bash
docker run --rm \
  -e OPENAI_API_KEY=$OPENAI_API_KEY \
  ghcr.io/jinalshah/devops/images/all-devops:latest \
  codex "generate terraform module for AWS VPC"
```

### GitHub Copilot CLI

**Setup**: GitHub authentication

```bash
docker run -it --rm \
  -v ~/.copilot:/root/.copilot \
  ghcr.io/jinalshah/devops/images/all-devops:latest \
  copilot auth login
```

**Usage**:

```bash
docker run --rm \
  -v ~/.copilot:/root/.copilot \
  ghcr.io/jinalshah/devops/images/all-devops:latest \
  copilot suggest "how to deploy to kubernetes"
```

### Google Gemini CLI

**Setup**: Use GCP credentials

```bash
# Requires gcloud authentication
docker run -it --rm \
  -v ~/.config/gcloud:/root/.config/gcloud \
  ghcr.io/jinalshah/devops/images/all-devops:latest \
  gemini --version
```

**Usage**:

```bash
docker run --rm \
  -v ~/.config/gcloud:/root/.config/gcloud \
  ghcr.io/jinalshah/devops/images/all-devops:latest \
  gemini "explain this error" --stdin < error.log
```

!!! info "AI CLI Setup Details"
    For comprehensive AI CLI setup guides, examples, and use cases, see:

    - [AI CLI Setup Guide](../tool-basics/ai-cli-setup.md) - Detailed authentication and configuration
    - [AI-Assisted DevOps Workflows](../workflows/ai-assisted-devops.md) - Real-world examples

---

## CI/CD Authentication

### GitHub Actions

```yaml
jobs:
  deploy:
    runs-on: ubuntu-latest
    container:
      image: ghcr.io/jinalshah/devops/images/aws-devops:latest

    steps:
      - uses: actions/checkout@v4

      - name: Configure AWS Credentials
        uses: aws-actions/configure-aws-credentials@v4
        with:
          aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
          aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
          aws-region: us-east-1

      - name: Deploy
        run: terraform apply -auto-approve
```

### GitLab CI

```yaml
deploy:
  image: registry.gitlab.com/jinal-shah/devops/images/aws-devops:latest
  script:
    - terraform apply -auto-approve
  variables:
    AWS_ACCESS_KEY_ID: $AWS_ACCESS_KEY_ID
    AWS_SECRET_ACCESS_KEY: $AWS_SECRET_ACCESS_KEY
    AWS_DEFAULT_REGION: us-east-1
```

### Environment Variables Summary

| Variable | Purpose | Example |
|----------|---------|---------|
| `AWS_ACCESS_KEY_ID` | AWS access key | `AKIAIOSFODNN7EXAMPLE` |
| `AWS_SECRET_ACCESS_KEY` | AWS secret key | `wJalrXUtnFEMI/K7MDENG/...` |
| `AWS_DEFAULT_REGION` | AWS region | `us-east-1` |
| `AWS_PROFILE` | AWS profile name | `staging` |
| `GOOGLE_APPLICATION_CREDENTIALS` | GCP service account key path | `/root/gcp-key.json` |
| `OPENAI_API_KEY` | OpenAI API key | `sk-...` |
| `SSH_AUTH_SOCK` | SSH agent socket | `/ssh-agent` |

---

## Troubleshooting Authentication

### AWS

```bash
# Verify AWS credentials
docker run --rm \
  -v ~/.aws:/root/.aws \
  ghcr.io/jinalshah/devops/images/aws-devops:latest \
  aws sts get-caller-identity

# Debug AWS configuration
docker run --rm \
  -v ~/.aws:/root/.aws \
  ghcr.io/jinalshah/devops/images/aws-devops:latest \
  aws configure list
```

### GCP

```bash
# Verify GCP authentication
docker run --rm \
  -v ~/.config/gcloud:/root/.config/gcloud \
  ghcr.io/jinalshah/devops/images/gcp-devops:latest \
  gcloud auth list

# Verify active project
docker run --rm \
  -v ~/.config/gcloud:/root/.config/gcloud \
  ghcr.io/jinalshah/devops/images/gcp-devops:latest \
  gcloud config get-value project
```

### Common Issues

!!! warning "Permission Denied on SSH Keys"
    **Problem**: SSH keys have incorrect permissions after mounting

    **Solution**:
    ```bash
    # Fix permissions inside container
    docker run -it --rm \
      -v ~/.ssh:/root/.ssh \
      ghcr.io/jinalshah/devops/images/all-devops:latest \
      chmod 600 /root/.ssh/id_rsa
    ```

!!! warning "AWS Credentials Not Found"
    **Problem**: `Unable to locate credentials`

    **Solution**: Ensure volume mount is correct
    ```bash
    # Verify mount
    docker run --rm \
      -v ~/.aws:/root/.aws \
      ghcr.io/jinalshah/devops/images/aws-devops:latest \
      ls -la /root/.aws
    ```

!!! warning "GCP Application Default Credentials Not Found"
    **Problem**: `Could not automatically determine credentials`

    **Solution**: Run `gcloud auth application-default login` on host first

---

## Security Best Practices

!!! danger "Never Commit Credentials"
    - ❌ Never commit `.aws/credentials`, `.env`, or service account keys to Git
    - ✅ Use volume mounts to inject credentials at runtime
    - ✅ Use CI/CD secrets for automated pipelines
    - ✅ Rotate credentials regularly
    - ✅ Use IAM roles when running on cloud platforms

!!! tip "Minimal Permissions"
    - Follow principle of least privilege
    - Create separate IAM users/service accounts for different projects
    - Use read-only credentials for testing
    - Enable MFA on cloud accounts

!!! tip "Credential Isolation"
    - Use different volume mounts for different projects
    - Don't share credentials between development and production
    - Consider using separate containers for sensitive operations

---

## Next Steps

- [AI CLI Setup Guide](../tool-basics/ai-cli-setup.md) - Comprehensive AI CLI authentication and usage
- [Quick Reference](quick-reference.md) - Common volume mount patterns
- [Troubleshooting](../troubleshooting/index.md) - Authentication error solutions
- [Workflows](../workflows/index.md) - Real-world CI/CD examples
