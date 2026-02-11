# GitHub Actions CI/CD Integration

Complete guide to using DevOps Images in GitHub Actions workflows for automated infrastructure deployment, testing, and validation.

!!! tip "Why GitHub Actions?"
    - Native GitHub integration
    - GHCR registry optimized for Actions
    - Generous free tier (2,000 minutes/month for private repos)
    - Extensive marketplace of actions

---

## Basic Setup

### Simple Terraform Deployment

Deploy infrastructure on every push to main:

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
      - uses: actions/checkout@v4  # (2)!

      - name: Configure AWS Credentials  # (3)!
        uses: aws-actions/configure-aws-credentials@v4
        with:
          aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
          aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
          aws-region: us-east-1

      - name: Terraform Deploy  # (4)!
        run: |
          terraform init
          terraform apply -auto-approve
```

1. Use immutable tag for reproducible builds
2. Checkout code into the container
3. Configure cloud credentials using official GitHub Actions
4. Run Terraform commands directly in the container

---

## Multi-Stage Pipeline

### Validate → Plan → Apply

Comprehensive workflow with validation, planning, and conditional deployment:

```yaml
name: Terraform Pipeline

on:
  pull_request:
    paths:
      - 'terraform/**'
  push:
    branches: [main]

jobs:
  validate:
    runs-on: ubuntu-latest
    container:
      image: ghcr.io/jinalshah/devops/images/all-devops:1.0.abc1234

    steps:
      - uses: actions/checkout@v4

      - name: Terraform Format Check
        run: terraform fmt -check -recursive

      - name: TFLint
        run: |
          cd terraform
          tflint --init
          tflint

      - name: Trivy Scan
        run: trivy config ./terraform

  plan:
    needs: validate
    runs-on: ubuntu-latest
    container:
      image: ghcr.io/jinalshah/devops/images/all-devops:1.0.abc1234

    steps:
      - uses: actions/checkout@v4

      - name: Configure AWS Credentials
        uses: aws-actions/configure-aws-credentials@v4
        with:
          aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
          aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
          aws-region: us-east-1

      - name: Terraform Plan
        run: |
          cd terraform
          terraform init
          terraform plan -out=tfplan

      - name: Upload Plan
        uses: actions/upload-artifact@v4
        with:
          name: terraform-plan
          path: terraform/tfplan

  apply:
    needs: plan
    if: github.ref == 'refs/heads/main'
    runs-on: ubuntu-latest
    container:
      image: ghcr.io/jinalshah/devops/images/all-devops:1.0.abc1234
    environment: production  # (1)!

    steps:
      - uses: actions/checkout@v4

      - name: Download Plan
        uses: actions/download-artifact@v4
        with:
          name: terraform-plan
          path: terraform

      - name: Configure AWS Credentials
        uses: aws-actions/configure-aws-credentials@v4
        with:
          aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
          aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
          aws-region: us-east-1

      - name: Terraform Apply
        run: |
          cd terraform
          terraform init
          terraform apply tfplan
```

1. Use GitHub Environments for approval gates and protection rules

---

## Multi-Cloud Deployment

### Deploy to Both AWS and GCP

```yaml
name: Multi-Cloud Deploy

on:
  workflow_dispatch:  # (1)!
    inputs:
      environment:
        description: 'Target environment'
        required: true
        type: choice
        options:
          - dev
          - staging
          - production

jobs:
  deploy-aws:
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

      - name: Deploy AWS Infrastructure
        run: |
          cd terraform/aws/${{ inputs.environment }}
          terraform init
          terraform apply -auto-approve

  deploy-gcp:
    runs-on: ubuntu-latest
    container:
      image: ghcr.io/jinalshah/devops/images/all-devops:1.0.abc1234

    steps:
      - uses: actions/checkout@v4

      - name: Configure GCP
        uses: google-github-actions/auth@v2
        with:
          credentials_json: ${{ secrets.GCP_SA_KEY }}

      - name: Deploy GCP Infrastructure
        run: |
          cd terraform/gcp/${{ inputs.environment }}
          terraform init
          terraform apply -auto-approve
```

1. Manual trigger with environment selection

---

## Matrix Builds

### Deploy to Multiple Environments

Deploy the same code to dev, staging, and production in parallel:

```yaml
name: Multi-Environment Deploy

on:
  push:
    branches: [main]

jobs:
  deploy:
    runs-on: ubuntu-latest
    strategy:
      matrix:
        environment: [dev, staging, production]
        cloud: [aws, gcp]
    container:
      image: ghcr.io/jinalshah/devops/images/all-devops:1.0.abc1234

    steps:
      - uses: actions/checkout@v4

      - name: Configure Credentials
        run: |
          # Configure based on matrix.cloud
          if [ "${{ matrix.cloud }}" == "aws" ]; then
            echo "Configuring AWS..."
          else
            echo "Configuring GCP..."
          fi

      - name: Deploy
        run: |
          cd terraform/${{ matrix.cloud }}/${{ matrix.environment }}
          terraform init
          terraform apply -auto-approve
```

---

## Security Scanning Workflow

### Comprehensive Security Checks

```yaml
name: Security Scan

on:
  pull_request:
  schedule:
    - cron: '0 0 * * 0'  # Weekly on Sundays

jobs:
  security-scan:
    runs-on: ubuntu-latest
    container:
      image: ghcr.io/jinalshah/devops/images/all-devops:1.0.abc1234

    steps:
      - uses: actions/checkout@v4

      - name: Trivy IaC Scan
        run: |
          trivy config ./terraform \
            --severity HIGH,CRITICAL \
            --exit-code 1

      - name: TFLint
        run: |
          cd terraform
          tflint --init
          tflint --minimum-failure-severity=error

      - name: CloudFormation Lint
        if: hashFiles('cloudformation/**/*.yaml') != ''
        run: |
          cfn-lint cloudformation/**/*.yaml

      - name: Ansible Lint
        if: hashFiles('ansible/**/*.yml') != ''
        run: |
          ansible-lint ansible/

      - name: Container Image Scan
        if: hashFiles('**/Dockerfile') != ''
        run: |
          trivy image --severity HIGH,CRITICAL my-app:latest
```

---

## Kubernetes Deployment

### Deploy to EKS/GKE with Helm

```yaml
name: Deploy to Kubernetes

on:
  push:
    branches: [main]

jobs:
  deploy-eks:
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

      - name: Update kubeconfig
        run: |
          aws eks update-kubeconfig \
            --region us-east-1 \
            --name my-eks-cluster

      - name: Deploy with Helm
        run: |
          helm upgrade --install myapp ./charts/myapp \
            --namespace production \
            --create-namespace \
            --wait \
            --timeout 5m

      - name: Verify Deployment
        run: |
          kubectl rollout status deployment/myapp -n production
          kubectl get pods -n production
```

---

## Caching Strategies

### Speed Up Pipeline with Caching

```yaml
name: Optimized Pipeline

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

      - name: Cache Terraform Plugins
        uses: actions/cache@v4
        with:
          path: |
            ~/.terraform.d/plugin-cache
          key: terraform-${{ hashFiles('**/.terraform.lock.hcl') }}

      - name: Configure Terraform Plugin Cache
        run: |
          mkdir -p ~/.terraform.d/plugin-cache
          cat > ~/.terraformrc <<EOF
          plugin_cache_dir = "$HOME/.terraform.d/plugin-cache"
          EOF

      - name: Terraform Init
        run: terraform init

      - name: Terraform Apply
        run: terraform apply -auto-approve
```

---

## AI-Assisted Code Review

### Automated Review with Claude CLI

```yaml
name: AI Code Review

on:
  pull_request:
    paths:
      - 'terraform/**'
      - 'ansible/**'

jobs:
  ai-review:
    runs-on: ubuntu-latest
    container:
      image: ghcr.io/jinalshah/devops/images/all-devops:1.0.abc1234

    steps:
      - uses: actions/checkout@v4

      - name: Setup Claude CLI
        run: |
          echo "${{ secrets.CLAUDE_API_KEY }}" > ~/.claude/config.json

      - name: Review Terraform Changes
        run: |
          git diff origin/main...HEAD -- terraform/ > changes.diff
          claude "Review this Terraform code for security issues and best practices" \
            --file changes.diff \
            > review-output.md

      - name: Post Review Comment
        uses: actions/github-script@v7
        with:
          script: |
            const fs = require('fs');
            const review = fs.readFileSync('review-output.md', 'utf8');
            github.rest.issues.createComment({
              issue_number: context.issue.number,
              owner: context.repo.owner,
              repo: context.repo.repo,
              body: `## 🤖 AI Code Review\n\n${review}`
            });
```

---

## Reusable Workflows

### Create Reusable Workflow

**`.github/workflows/terraform-deploy.yml`**:

```yaml
name: Reusable Terraform Deploy

on:
  workflow_call:
    inputs:
      environment:
        required: true
        type: string
      terraform_dir:
        required: true
        type: string
    secrets:
      AWS_ACCESS_KEY_ID:
        required: true
      AWS_SECRET_ACCESS_KEY:
        required: true

jobs:
  deploy:
    runs-on: ubuntu-latest
    container:
      image: ghcr.io/jinalshah/devops/images/all-devops:1.0.abc1234
    environment: ${{ inputs.environment }}

    steps:
      - uses: actions/checkout@v4

      - name: Configure AWS
        uses: aws-actions/configure-aws-credentials@v4
        with:
          aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
          aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
          aws-region: us-east-1

      - name: Terraform Deploy
        run: |
          cd ${{ inputs.terraform_dir }}
          terraform init
          terraform apply -auto-approve
```

**Use the reusable workflow**:

```yaml
name: Deploy All Environments

on:
  push:
    branches: [main]

jobs:
  deploy-dev:
    uses: ./.github/workflows/terraform-deploy.yml
    with:
      environment: dev
      terraform_dir: terraform/dev
    secrets: inherit

  deploy-staging:
    needs: deploy-dev
    uses: ./.github/workflows/terraform-deploy.yml
    with:
      environment: staging
      terraform_dir: terraform/staging
    secrets: inherit

  deploy-prod:
    needs: deploy-staging
    uses: ./.github/workflows/terraform-deploy.yml
    with:
      environment: production
      terraform_dir: terraform/production
    secrets: inherit
```

---

## Best Practices

!!! tip "Performance Optimization"

    1. **Pin image versions**: Use immutable tags like `1.0.abc1234`
    2. **Cache layers**: GitHub automatically caches container layers
    3. **Use GHCR**: Fastest registry for GitHub Actions
    4. **Cache Terraform plugins**: Use `actions/cache` for `.terraform` directory
    5. **Parallel jobs**: Run independent steps in parallel

!!! tip "Security Best Practices"

    1. **Use GitHub Secrets**: Store credentials in repository or organization secrets
    2. **Use Environments**: Add approval gates for production deployments
    3. **Limit permissions**: Use `permissions:` to grant minimal access
    4. **Scan before deploy**: Run Trivy/TFLint in validation job
    5. **Use OIDC**: Consider AWS/GCP OIDC instead of static credentials

!!! warning "Common Pitfalls"

    - ❌ **Using `latest` tag**: Leads to non-reproducible builds
    - ❌ **Hardcoding credentials**: Always use GitHub Secrets
    - ❌ **No approval gates**: Use Environments for production
    - ❌ **Ignoring scan results**: Make security checks blocking

---

## Troubleshooting

??? question "Container fails to start"

    **Problem**: GitHub Actions can't pull or run the container

    **Solutions**:
    ```yaml
    # 1. Verify image name and tag
    container:
      image: ghcr.io/jinalshah/devops/images/all-devops:1.0.abc1234

    # 2. For private images, authenticate
    container:
      image: ghcr.io/private/image:latest
      credentials:
        username: ${{ github.actor }}
        password: ${{ secrets.GITHUB_TOKEN }}
    ```

??? question "Terraform state locking issues"

    **Problem**: Multiple jobs try to access Terraform state simultaneously

    **Solution**: Use job dependencies or concurrency groups
    ```yaml
    concurrency:
      group: terraform-${{ github.ref }}
      cancel-in-progress: false
    ```

??? question "AWS credentials not working"

    **Problem**: AWS CLI can't find credentials in container

    **Solution**: Ensure `aws-actions/configure-aws-credentials` runs before AWS commands
    ```yaml
    - name: Configure AWS Credentials
      uses: aws-actions/configure-aws-credentials@v4
      with:
        aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
        aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
        aws-region: us-east-1
    ```

---

## Example Repository Structure

```
.
├── .github/
│   └── workflows/
│       ├── terraform-pipeline.yml
│       ├── security-scan.yml
│       ├── k8s-deploy.yml
│       └── reusable/
│           └── terraform-deploy.yml
├── terraform/
│   ├── dev/
│   ├── staging/
│   └── production/
├── ansible/
│   └── playbooks/
└── charts/
    └── myapp/
```

---

## Next Steps

- [GitLab CI Integration](ci-cd-gitlab.md) - GitLab CI examples
- [Jenkins Integration](ci-cd-jenkins.md) - Jenkins pipeline examples
- [CircleCI Integration](ci-cd-circleci.md) - CircleCI config examples
- [AI-Assisted DevOps](ai-assisted-devops.md) - AI workflow automation
- [Multi-Tool Patterns](multi-tool-patterns.md) - Combining multiple tools
