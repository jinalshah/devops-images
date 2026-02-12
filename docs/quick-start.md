# Quick Start Guide

Get up and running with DevOps Images in 5 minutes.

## 5-Minute Quickstart

- [ ] **Step 1**: Choose your image
- [ ] **Step 2**: Pull the image
- [ ] **Step 3**: Run interactively
- [ ] **Step 4**: Test a tool
- [ ] **Step 5**: Set up for real work

### Step 1: Choose Your Image

!!! question "Which image do I need?"

    **Quick decision**:

    - **Multi-cloud or exploring?** → `all-devops`
    - **AWS only?** → `aws-devops`
    - **GCP only?** → `gcp-devops`

    Need help deciding? See the [complete decision guide](choosing-an-image.md).

### Step 2: Pull the Image

=== "all-devops (Recommended)"

    ```bash
    docker pull ghcr.io/jinalshah/devops/images/all-devops:latest
    ```

    **Contains**: AWS + GCP + all base tools (~3.2 GB)

=== "aws-devops"

    ```bash
    docker pull ghcr.io/jinalshah/devops/images/aws-devops:latest
    ```

    **Contains**: AWS + all base tools (~2.8 GB)

=== "gcp-devops"

    ```bash
    docker pull ghcr.io/jinalshah/devops/images/gcp-devops:latest
    ```

    **Contains**: GCP + all base tools (~2.9 GB)

!!! tip "First pull takes time"
    Initial pull downloads ~3 GB. Subsequent runs are instant. Grab a coffee! ☕

### Step 3: Run Interactively

```bash
docker run -it --rm ghcr.io/jinalshah/devops/images/all-devops:latest
```

You should see a `zsh` prompt with Oh My Zsh configured:

```
➜ /
```

!!! success "You're in!"
    You're now inside the container with access to all tools.

### Step 4: Test a Tool

Try a few commands to verify everything works:

```bash
# Check Terraform
terraform version

# Check kubectl
kubectl version --client

# Check AWS CLI (all-devops or aws-devops)
aws --version

# Check gcloud (all-devops or gcp-devops)
gcloud version

# Check AI CLI
claude --version

# Exit when done
exit
```

!!! example "Expected Output"
    You should see version information for each tool, indicating they're installed and working.

### Step 5: Set Up for Real Work

Now run with your project files and credentials mounted:

```bash
docker run -it --rm \
  -v $PWD:/workspace \
  -v ~/.ssh:/root/.ssh \
  -v ~/.aws:/root/.aws \
  -v ~/.config/gcloud:/root/.config/gcloud \
  -w /workspace \
  ghcr.io/jinalshah/devops/images/all-devops:latest
```

!!! success "Ready to work!"
    You can now access your project files in `/workspace` and use cloud CLIs with your credentials.

---

## What You Get

### All Images Include

✅ **Infrastructure as Code**

- Terraform (multi-version)
- Terragrunt
- TFLint
- Packer

✅ **Kubernetes**

- kubectl
- Helm 3
- k9s

✅ **Configuration & Security**

- Ansible + ansible-lint
- Trivy
- pre-commit

✅ **AI CLI Tools**

- Claude CLI (Anthropic)
- Codex CLI (OpenAI)
- Copilot CLI (GitHub)
- Gemini CLI (Google)

✅ **Development**

- Python 3.12
- Node.js LTS
- Git + GitHub CLI
- Database clients (mongosh, psql, mysql)

✅ **Shells & Utils**

- Zsh (default) with Oh My Zsh
- Bash, Fish
- jq, curl, wget, vim

### Cloud-Specific Tools

=== "all-devops"

    ✅ AWS CLI v2 + Session Manager
    ✅ gcloud + docker-credential-gcr
    ✅ boto3, cfn-lint, s3cmd

=== "aws-devops"

    ✅ AWS CLI v2 + Session Manager
    ✅ boto3, cfn-lint, s3cmd
    ❌ No GCP tools

=== "gcp-devops"

    ✅ gcloud + docker-credential-gcr
    ❌ No AWS tools

---

## Common First Tasks

### Task 1: Run Terraform

```bash
# Create a simple test file
cat > main.tf <<'EOF'
terraform {
  required_version = ">= 1.0"
}

output "hello" {
  value = "Hello from DevOps Images!"
}
EOF

# Run Terraform
docker run --rm -v $PWD:/workspace -w /workspace \
  ghcr.io/jinalshah/devops/images/all-devops:latest \
  sh -c "terraform init && terraform apply -auto-approve"
```

### Task 2: Scan for Vulnerabilities

```bash
# Scan current directory
docker run --rm -v $PWD:/workspace \
  ghcr.io/jinalshah/devops/images/all-devops:latest \
  trivy fs /workspace
```

### Task 3: Validate Kubernetes Manifests

```bash
# Assuming you have k8s manifests
docker run --rm -v $PWD:/workspace -w /workspace \
  ghcr.io/jinalshah/devops/images/all-devops:latest \
  kubectl apply --dry-run=client -f kubernetes/
```

### Task 4: Use AI CLI

```bash
# First-time setup: authenticate
docker run -it --rm \
  -v ~/.claude:/root/.claude \
  ghcr.io/jinalshah/devops/images/all-devops:latest \
  claude auth login

# Use Claude for code review
docker run --rm \
  -v $PWD:/workspace \
  -v ~/.claude:/root/.claude \
  -w /workspace \
  ghcr.io/jinalshah/devops/images/all-devops:latest \
  claude "Review this Terraform file for security issues" \
  --file main.tf
```

---

## Next Steps by Use Case

### For Local Development

1. **Mount your project**: Use `-v $PWD:/workspace`
2. **Mount credentials**: Add `-v ~/.aws:/root/.aws` and `-v ~/.config/gcloud:/root/.config/gcloud`
3. **Named container**: Use `--name devops-work` to easily restart
4. **Authentication**: Set up [cloud credentials](use-images/authentication.md) and [AI CLIs](tool-basics/ai-cli-setup.md)

**Full command**:
```bash
docker run -it --name devops-work \
  -v $PWD:/workspace \
  -v ~/.ssh:/root/.ssh \
  -v ~/.aws:/root/.aws \
  -v ~/.config/gcloud:/root/.config/gcloud \
  -v ~/.claude:/root/.claude \
  -w /workspace \
  ghcr.io/jinalshah/devops/images/all-devops:latest
```

### For CI/CD

1. **Pin versions**: Use immutable tags like `1.0.abc1234`
2. **Use secrets**: Configure cloud credentials via CI secrets
3. **Cache images**: Pre-pull during setup phase
4. **GHCR registry**: Use `ghcr.io` for best performance

**Example** (GitHub Actions):
```yaml
container:
  image: ghcr.io/jinalshah/devops/images/all-devops:1.0.abc1234
```

**Learn more**: [CI/CD Integration](workflows/index.md)

### For Multi-Cloud Teams

1. **Use all-devops**: Maximum flexibility
2. **Workflows**: Check [multi-cloud patterns](workflows/multi-tool-patterns.md)
3. **Authentication**: Set up both [AWS and GCP](use-images/authentication.md)
4. **Organise**: Use subdirectories for cloud-specific configs

### For Security-Focused Teams

1. **Scan everything**: Use Trivy for containers and IaC
2. **Lint configs**: TFLint for Terraform, ansible-lint for Ansible
3. **AI review**: Use Claude for security audits
4. **Pin versions**: Lock to specific image versions
5. **Scan images**: Run `trivy image` on the DevOps Images themselves

**Learn more**: [Security workflows](workflows/multi-tool-patterns.md#pattern-2-security-first-workflow)

---

## Troubleshooting First Run

??? question "Docker: command not found"

    **Problem**: Docker is not installed

    **Solution**: Install Docker Desktop

    - [macOS](https://docs.docker.com/desktop/install/mac-install/)
    - [Windows](https://docs.docker.com/desktop/install/windows-install/)
    - [Linux](https://docs.docker.com/engine/install/)

??? question "Cannot connect to Docker daemon"

    **Problem**: Docker daemon is not running

    **Solution**: Start Docker Desktop or Docker service

    ```bash
    # Linux
    sudo systemctl start docker

    # macOS/Windows
    # Start Docker Desktop application
    ```

??? question "Permission denied while trying to connect"

    **Problem**: User doesn't have Docker permissions

    **Solution**: Add user to docker group (Linux)

    ```bash
    sudo usermod -aG docker $USER
    # Log out and back in for changes to take effect
    ```

??? question "Image pull is very slow"

    **Problem**: Large image size or slow internet

    **Solutions**:

    1. Use GHCR instead of Docker Hub (faster)
    2. Use smaller cloud-specific images
    3. Wait for initial pull (only happens once)
    4. Use a wired connection if possible

??? question "Tools returning 'command not found'"

    **Problem**: Wrong image or tool not included

    **Solutions**:

    1. Verify you pulled the correct image
    2. Check tool availability in [image comparison](choosing-an-image.md)
    3. For cloud CLIs, ensure you're using the right image variant

---

## Quick Reference Card

### Essential Commands

```bash
# Pull latest image
docker pull ghcr.io/jinalshah/devops/images/all-devops:latest

# Run interactively
docker run -it --rm ghcr.io/jinalshah/devops/images/all-devops:latest

# Run with project mounted
docker run -it --rm \
  -v $PWD:/workspace -w /workspace \
  ghcr.io/jinalshah/devops/images/all-devops:latest

# Run single command
docker run --rm \
  -v $PWD:/workspace -w /workspace \
  ghcr.io/jinalshah/devops/images/all-devops:latest \
  terraform plan

# Check versions
docker run --rm ghcr.io/jinalshah/devops/images/all-devops:latest terraform version
docker run --rm ghcr.io/jinalshah/devops/images/all-devops:latest aws --version
```

### Common Volume Mounts

| Mount | Purpose |
|-------|---------|
| `-v $PWD:/workspace` | Project files |
| `-v ~/.aws:/root/.aws` | AWS credentials |
| `-v ~/.config/gcloud:/root/.config/gcloud` | GCP credentials |
| `-v ~/.ssh:/root/.ssh` | SSH keys |
| `-v ~/.kube:/root/.kube` | Kubernetes config |
| `-v ~/.claude:/root/.claude` | Claude AI credentials |

### Useful Aliases

Add to your `~/.bashrc` or `~/.zshrc`:

```bash
# Quick access to DevOps container
alias devops='docker run -it --rm \
  -v $PWD:/workspace \
  -v ~/.ssh:/root/.ssh \
  -v ~/.aws:/root/.aws \
  -v ~/.config/gcloud:/root/.config/gcloud \
  -w /workspace \
  ghcr.io/jinalshah/devops/images/all-devops:latest'

# One-off commands
alias devops-run='docker run --rm \
  -v $PWD:/workspace -w /workspace \
  ghcr.io/jinalshah/devops/images/all-devops:latest'

# Example usage:
# devops                          # Interactive shell
# devops-run terraform plan       # Single command
```

---

## What's Next?

🎯 **Ready to go deeper?**

**Learn the Tools**:

- [Tool Basics Guide](tool-basics/index.md) - Comprehensive tool reference
- [AI CLI Setup](tool-basics/ai-cli-setup.md) - Claude, Codex, Copilot, Gemini

**Set Up Credentials**:

- [Authentication Guide](use-images/authentication.md) - AWS, GCP, SSH, AI CLIs

**See Real Examples**:

- [Workflows & Patterns](workflows/index.md) - CI/CD integrations
- [AI-Assisted DevOps](workflows/ai-assisted-devops.md) - AI workflow examples
- [Multi-Tool Patterns](workflows/multi-tool-patterns.md) - Combining tools

**Understand the Images**:

- [Architecture Overview](architecture/index.md) - What's inside
- [Choosing an Image](choosing-an-image.md) - Detailed comparison
- [Build & Optimise](build-images/index.md) - Custom builds

**Get Help**:

- [Troubleshooting](troubleshooting/index.md) - Common issues
- [GitHub Issues](https://github.com/jinalshah/devops-images/issues) - Report problems

---

🚀 **You're all set! Happy DevOps-ing!**
