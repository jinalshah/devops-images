# AI CLI Setup & Usage

Comprehensive guide to setting up and using the AI CLI tools (Claude, Codex, Copilot, Gemini) included in DevOps Images for AI-assisted infrastructure development.

!!! tip "Why AI CLI Tools?"
    - **Code generation**: Generate Infrastructure as Code from natural language
    - **Code review**: Automated security and best practice reviews
    - **Troubleshooting**: Debug errors and get solutions
    - **Documentation**: Auto-generate documentation from code
    - **Learning**: Get explanations of complex configurations

---

## Available AI CLIs

| Tool | Provider | Best For | API Required |
|------|----------|----------|--------------|
| **claude** | Anthropic | Code review, architecture design, complex reasoning | ✅ Anthropic API Key |
| **codex** | OpenAI | Code generation, completion | ✅ OpenAI API Key |
| **copilot** | GitHub | IDE integration, inline suggestions | ✅ GitHub Copilot subscription |
| **gemini** | Google | Multi-modal tasks, GCP integration | ✅ Google AI API Key |

---

## Claude CLI Setup

### Get API Key

1. Visit [Anthropic Console](https://console.anthropic.com/)
2. Sign up or log in
3. Navigate to API Keys
4. Create new API key
5. Copy the key (starts with `sk-ant-`)

### Configure Claude CLI

=== "Interactive Setup"

    ```bash
    docker run -it --rm \
      -v ~/.claude:/root/.claude \
      ghcr.io/jinalshah/devops/images/all-devops:latest \
      claude auth login
    ```

    Follow the prompts to enter your API key.

=== "Environment Variable"

    ```bash
    docker run -it --rm \
      -v $PWD:/workspace \
      -e ANTHROPIC_API_KEY=sk-ant-... \
      -w /workspace \
      ghcr.io/jinalshah/devops/images/all-devops:latest \
      claude "Review this code" --file main.tf
    ```

=== "Config File"

    Create `~/.claude/config.json`:
    ```json
    {
      "api_key": "sk-ant-..."
    }
    ```

    Then mount it:
    ```bash
    docker run -it --rm \
      -v $PWD:/workspace \
      -v ~/.claude:/root/.claude \
      -w /workspace \
      ghcr.io/jinalshah/devops/images/all-devops:latest
    ```

### Usage Examples

#### Code Review

```bash
docker run --rm \
  -v $PWD:/workspace \
  -v ~/.claude:/root/.claude \
  -w /workspace \
  ghcr.io/jinalshah/devops/images/all-devops:latest \
  claude "Review this Terraform code for security issues and best practices" \
    --file terraform/main.tf
```

#### Generate Infrastructure Code

```bash
docker run --rm \
  -v $PWD:/workspace \
  -v ~/.claude:/root/.claude \
  -w /workspace \
  ghcr.io/jinalshah/devops/images/all-devops:latest \
  claude "Generate Terraform code to create an AWS VPC with 3 public and 3 private subnets" \
    > vpc.tf
```

#### Explain Complex Configuration

```bash
docker run --rm \
  -v $PWD:/workspace \
  -v ~/.claude:/root/.claude \
  -w /workspace \
  ghcr.io/jinalshah/devops/images/all-devops:latest \
  claude "Explain what this Ansible playbook does" \
    --file ansible/deploy.yml
```

#### Debug Errors

```bash
# Save error output
terraform apply 2>&1 | tee error.log

# Ask Claude to debug
docker run --rm \
  -v $PWD:/workspace \
  -v ~/.claude:/root/.claude \
  -w /workspace \
  ghcr.io/jinalshah/devops/images/all-devops:latest \
  claude "This Terraform apply failed. What's wrong and how do I fix it?" \
    --file error.log
```

---

## Codex CLI Setup

### Get API Key

1. Visit [OpenAI Platform](https://platform.openai.com/)
2. Sign up or log in
3. Navigate to API Keys
4. Create new API key
5. Copy the key (starts with `sk-`)

### Configure Codex CLI

=== "Environment Variable"

    ```bash
    docker run -it --rm \
      -v $PWD:/workspace \
      -e OPENAI_API_KEY=sk-... \
      -w /workspace \
      ghcr.io/jinalshah/devops/images/all-devops:latest \
      codex "Generate Python script to list all S3 buckets"
    ```

=== "Config File"

    Create `~/.codex/config.json`:
    ```json
    {
      "api_key": "sk-..."
    }
    ```

    Mount it:
    ```bash
    docker run -it --rm \
      -v $PWD:/workspace \
      -v ~/.codex:/root/.codex \
      -w /workspace \
      ghcr.io/jinalshah/devops/images/all-devops:latest
    ```

### Usage Examples

#### Generate Scripts

```bash
docker run --rm \
  -v $PWD:/workspace \
  -v ~/.codex:/root/.codex \
  -w /workspace \
  ghcr.io/jinalshah/devops/images/all-devops:latest \
  codex "Create a bash script to backup PostgreSQL database to S3" \
    > backup.sh
```

#### Code Completion

```bash
# Complete partial code
docker run --rm \
  -v $PWD:/workspace \
  -v ~/.codex:/root/.codex \
  -w /workspace \
  ghcr.io/jinalshah/devops/images/all-devops:latest \
  codex --complete \
    --file partial-script.py
```

---

## GitHub Copilot CLI Setup

### Get Access

1. Subscribe to [GitHub Copilot](https://github.com/features/copilot)
2. Install GitHub Copilot CLI extension
3. Authenticate with GitHub

### Configure Copilot CLI

```bash
docker run -it --rm \
  -v ~/.copilot:/root/.copilot \
  ghcr.io/jinalshah/devops/images/all-devops:latest \
  copilot auth login
```

### Usage Examples

#### Suggest Commands

```bash
docker run --rm \
  -v $PWD:/workspace \
  -v ~/.copilot:/root/.copilot \
  -w /workspace \
  ghcr.io/jinalshah/devops/images/all-devops:latest \
  copilot suggest "deploy kubernetes application with helm"
```

#### Explain Commands

```bash
docker run --rm \
  -v ~/.copilot:/root/.copilot \
  ghcr.io/jinalshah/devops/images/all-devops:latest \
  copilot explain "kubectl rollout status deployment/myapp -n production"
```

---

## Gemini CLI Setup

### Get API Key

1. Visit [Google AI Studio](https://makersuite.google.com/app/apikey)
2. Sign in with Google account
3. Create API key
4. Copy the key

### Configure Gemini CLI

=== "Environment Variable"

    ```bash
    docker run -it --rm \
      -v $PWD:/workspace \
      -e GOOGLE_API_KEY=... \
      -w /workspace \
      ghcr.io/jinalshah/devops/images/all-devops:latest \
      gemini "Generate GCP deployment manager template"
    ```

=== "Config File"

    Create `~/.gemini/config.json`:
    ```json
    {
      "api_key": "..."
    }
    ```

    Mount it:
    ```bash
    docker run -it --rm \
      -v $PWD:/workspace \
      -v ~/.gemini:/root/.gemini \
      -w /workspace \
      ghcr.io/jinalshah/devops/images/all-devops:latest
    ```

### Usage Examples

#### GCP-Specific Tasks

```bash
docker run --rm \
  -v $PWD:/workspace \
  -v ~/.gemini:/root/.gemini \
  -w /workspace \
  ghcr.io/jinalshah/devops/images/all-devops:latest \
  gemini "Create a Cloud Run service with auto-scaling" \
    > cloud-run.yaml
```

#### Multi-Modal Analysis

```bash
# Analyze architecture diagram
docker run --rm \
  -v $PWD:/workspace \
  -v ~/.gemini:/root/.gemini \
  -w /workspace \
  ghcr.io/jinalshah/devops/images/all-devops:latest \
  gemini "Describe this infrastructure architecture" \
    --image architecture.png
```

---

## Real-World Workflows

### Workflow 1: Security-First Development

```bash
#!/bin/bash
# secure-deploy.sh

# 1. Generate infrastructure code with Claude
docker run --rm \
  -v $PWD:/workspace \
  -v ~/.claude:/root/.claude \
  -w /workspace \
  ghcr.io/jinalshah/devops/images/all-devops:latest \
  claude "Generate secure AWS EKS cluster with encrypted EBS volumes and VPC endpoints" \
  > eks-cluster.tf

# 2. Review with Claude
docker run --rm \
  -v $PWD:/workspace \
  -v ~/.claude:/root/.claude \
  -w /workspace \
  ghcr.io/jinalshah/devops/images/all-devops:latest \
  claude "Review this EKS cluster code for security issues" \
    --file eks-cluster.tf \
  > security-review.md

# 3. Scan with Trivy
docker run --rm \
  -v $PWD:/workspace \
  -w /workspace \
  ghcr.io/jinalshah/devops/images/all-devops:latest \
  trivy config eks-cluster.tf

# 4. Deploy
docker run --rm \
  -v $PWD:/workspace \
  -v ~/.aws:/root/.aws \
  -w /workspace \
  ghcr.io/jinalshah/devops/images/all-devops:latest \
  sh -c "terraform init && terraform apply"
```

### Workflow 2: AI-Assisted Troubleshooting

```bash
#!/bin/bash
# ai-troubleshoot.sh

# Capture error
kubectl apply -f deployment.yaml 2>&1 | tee error.log

# Get AI help
docker run --rm \
  -v $PWD:/workspace \
  -v ~/.claude:/root/.claude \
  -w /workspace \
  ghcr.io/jinalshah/devops/images/all-devops:latest \
  claude "This Kubernetes deployment failed. Analyze the error and provide a fix." \
    --file error.log \
    --file deployment.yaml \
  > solution.md

cat solution.md
```

### Workflow 3: Documentation Generation

```bash
#!/bin/bash
# generate-docs.sh

# Generate README for Terraform module
docker run --rm \
  -v $PWD:/workspace \
  -v ~/.claude:/root/.claude \
  -w /workspace \
  ghcr.io/jinalshah/devops/images/all-devops:latest \
  claude "Generate comprehensive README.md documentation for this Terraform module" \
    --file main.tf \
    --file variables.tf \
    --file outputs.tf \
  > README.md
```

### Workflow 4: Multi-Cloud Translation

```bash
# Translate AWS to GCP
docker run --rm \
  -v $PWD:/workspace \
  -v ~/.claude:/root/.claude \
  -w /workspace \
  ghcr.io/jinalshah/devops/images/all-devops:latest \
  claude "Convert this AWS Terraform code to equivalent GCP resources" \
    --file aws/main.tf \
  > gcp/main.tf
```

---

## Comparison Matrix

### When to Use Which AI CLI?

| Use Case | Claude | Codex | Copilot | Gemini |
|----------|--------|-------|---------|--------|
| **Security review** | ✅ Best | ⚠️ Good | ⚠️ Good | ⚠️ Good |
| **Code generation** | ✅ Best | ✅ Best | ✅ Best | ✅ Best |
| **Architecture design** | ✅ Best | ⚠️ Good | ❌ Limited | ⚠️ Good |
| **Troubleshooting** | ✅ Best | ⚠️ Good | ⚠️ Good | ⚠️ Good |
| **Multi-modal (images)** | ❌ No | ❌ No | ❌ No | ✅ Yes |
| **GCP-specific tasks** | ⚠️ Good | ⚠️ Good | ⚠️ Good | ✅ Best |
| **Cost** | $$ | $$ | $ | Free tier |

**Recommendations**:

- **General DevOps**: Claude (best reasoning)
- **Quick code snippets**: Codex or Copilot
- **GCP workloads**: Gemini
- **Visual analysis**: Gemini (only one with multi-modal)

---

## Best Practices

!!! tip "Effective AI Usage"

    1. **Be specific**: Detailed prompts get better results
    2. **Provide context**: Include relevant files with `--file`
    3. **Iterate**: Refine prompts based on output
    4. **Review output**: Always review AI-generated code
    5. **Combine tools**: Use Trivy/TFLint alongside AI review

!!! tip "Security"

    1. **Never expose API keys**: Use environment variables or mounted config files
    2. **Review before deploy**: AI-generated code should always be reviewed
    3. **Scan AI output**: Run security scanners on generated code
    4. **Cost awareness**: Monitor API usage to avoid unexpected bills
    5. **Rotate keys**: Regularly rotate API keys

!!! warning "Limitations"

    - ❌ **AI makes mistakes**: Always review output
    - ❌ **Not always up-to-date**: May suggest deprecated approaches
    - ❌ **Context limits**: Large files may be truncated
    - ❌ **Costs add up**: Monitor usage

---

## Cost Management

### Track Usage

```bash
# Create usage tracking script
cat > track-ai-usage.sh <<'EOF'
#!/bin/bash
DATE=$(date +%Y-%m-%d)
USAGE_LOG="ai-usage-$DATE.log"

echo "$(date): Claude API call" >> $USAGE_LOG
docker run --rm \
  -v $PWD:/workspace \
  -v ~/.claude:/root/.claude \
  -w /workspace \
  ghcr.io/jinalshah/devops/images/all-devops:latest \
  claude "$@"
EOF

chmod +x track-ai-usage.sh
```

### Cost Estimates (Approximate)

| Provider | Model | Cost per 1M tokens (input) | Cost per 1M tokens (output) |
|----------|-------|---------------------------|----------------------------|
| **Anthropic** | Claude 3.5 Sonnet | $3 | $15 |
| **OpenAI** | GPT-4 Turbo | $10 | $30 |
| **GitHub** | Copilot | $10/month (unlimited) | N/A |
| **Google** | Gemini Pro | Free tier, then $0.50 | $1.50 |

---

## Troubleshooting

??? question "API key not working"

    **Problem**: Authentication error when using AI CLI

    **Solutions**:
    1. Verify API key is correct and active
    2. Check config file permissions:
       ```bash
       chmod 600 ~/.claude/config.json
       ```
    3. Ensure container can access mounted config:
       ```bash
       docker run --rm -v ~/.claude:/root/.claude \
         ghcr.io/jinalshah/devops/images/all-devops:latest \
         ls -la /root/.claude
       ```

??? question "Rate limit exceeded"

    **Problem**: Too many API requests

    **Solutions**:
    1. Add delays between requests
    2. Upgrade to higher tier plan
    3. Batch requests when possible
    4. Cache responses locally

??? question "Context too long"

    **Problem**: Input file too large for AI model

    **Solutions**:
    1. Split large files into chunks
    2. Provide only relevant sections
    3. Use summary/extract approach:
       ```bash
       # First, summarize
       claude "Summarize the main components of this file" --file large-file.tf

       # Then, ask specific questions
       claude "Review the VPC configuration" --file large-file.tf
       ```

---

## Advanced Integration

### Pre-commit Hook with AI Review

**`.pre-commit-config.yaml`**:

```yaml
repos:
  - repo: local
    hooks:
      - id: ai-code-review
        name: AI Code Review
        entry: ./scripts/ai-review.sh
        language: system
        files: \.(tf|yml|yaml)$
        pass_filenames: true
```

**`scripts/ai-review.sh`**:

```bash
#!/bin/bash
for file in "$@"; do
  docker run --rm \
    -v $PWD:/workspace \
    -v ~/.claude:/root/.claude \
    -w /workspace \
    ghcr.io/jinalshah/devops/images/all-devops:latest \
    claude "Quick security review of this file" --file "$file"
done
```

### CI/CD Integration

See [AI-Assisted DevOps Workflows](../workflows/ai-assisted-devops.md) for complete CI/CD integration examples.

---

## Next Steps

- [AI-Assisted DevOps Workflows](../workflows/ai-assisted-devops.md) - Complete workflow examples
- [Authentication Guide](../use-images/authentication.md) - Mount AI credentials in containers
- [Multi-Tool Patterns](../workflows/multi-tool-patterns.md) - Combine AI with other DevOps tools
- [Security Workflows](../workflows/multi-tool-patterns.md#pattern-2-security-first-workflow) - AI + security scanning
