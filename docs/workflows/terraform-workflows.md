# Terraform Workflows & Patterns

Advanced Terraform workflow patterns using DevOps Images for infrastructure as code management, state handling, and multi-environment deployments.

---

## Basic Terraform Workflow

### Standard Development Cycle

```bash
# Interactive container with project mounted
docker run -it --rm \
  -v $PWD:/workspace \
  -v ~/.aws:/root/.aws \
  -w /workspace \
  ghcr.io/jinalshah/devops/images/all-devops:latest

# Inside container
terraform init
terraform validate
terraform plan
terraform apply
```

---

## Multi-Environment Management

### Directory Structure

```
terraform/
├── environments/
│   ├── dev/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── terraform.tfvars
│   ├── staging/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── terraform.tfvars
│   └── production/
│       ├── main.tf
│       ├── variables.tf
│       └── terraform.tfvars
└── modules/
    ├── vpc/
    ├── eks/
    └── rds/
```

### Deploy All Environments

```bash
#!/bin/bash
# deploy-all.sh

ENVIRONMENTS=("dev" "staging" "production")

for ENV in "${ENVIRONMENTS[@]}"; do
  echo "Deploying to $ENV..."

  docker run --rm \
    -v $PWD:/workspace \
    -v ~/.aws:/root/.aws \
    -w /workspace/environments/$ENV \
    ghcr.io/jinalshah/devops/images/all-devops:latest \
    sh -c "
      terraform init
      terraform plan -out=tfplan
      terraform apply tfplan
    "
done
```

---

## Terragrunt Patterns

### DRY Configuration with Terragrunt

**Project structure**:

```
infrastructure/
├── terragrunt.hcl          # Root config
├── dev/
│   └── terragrunt.hcl
├── staging/
│   └── terragrunt.hcl
└── production/
    └── terragrunt.hcl
```

**Root `terragrunt.hcl`**:

```hcl
remote_state {
  backend = "s3"
  config = {
    bucket         = "my-terraform-state-${get_aws_account_id()}"
    key            = "${path_relative_to_include()}/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "terraform-locks"
  }
}
```

**Deploy with Terragrunt**:

```bash
docker run --rm \
  -v $PWD:/workspace \
  -v ~/.aws:/root/.aws \
  -w /workspace \
  ghcr.io/jinalshah/devops/images/all-devops:latest \
  sh -c "
    cd dev
    terragrunt run-all plan
    terragrunt run-all apply
  "
```

---

## State Management

### Remote State with S3 Backend

**backend.tf**:

```hcl
terraform {
  backend "s3" {
    bucket         = "my-terraform-state"
    key            = "production/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "terraform-locks"
  }
}
```

### State Operations

```bash
# View current state
docker run --rm \
  -v $PWD:/workspace \
  -v ~/.aws:/root/.aws \
  -w /workspace \
  ghcr.io/jinalshah/devops/images/all-devops:latest \
  terraform show

# List resources in state
docker run --rm \
  -v $PWD:/workspace \
  -v ~/.aws:/root/.aws \
  -w /workspace \
  ghcr.io/jinalshah/devops/images/all-devops:latest \
  terraform state list

# Move resource in state
docker run --rm \
  -v $PWD:/workspace \
  -v ~/.aws:/root/.aws \
  -w /workspace \
  ghcr.io/jinalshah/devops/images/all-devops:latest \
  terraform state mv aws_instance.old aws_instance.new
```

---

## Version Management with tfswitch

### Switch Terraform Versions

The DevOps Image includes `tfswitch` for managing multiple Terraform versions:

```bash
docker run --rm \
  -v $PWD:/workspace \
  -w /workspace \
  ghcr.io/jinalshah/devops/images/all-devops:latest \
  sh -c "
    # Switch to specific version
    tfswitch 1.6.0

    # Verify version
    terraform version

    # Run Terraform
    terraform init
    terraform plan
  "
```

**Using `.terraform-version` file**:

```bash
# Create version file
echo "1.6.0" > .terraform-version

# tfswitch automatically uses version from file
docker run --rm \
  -v $PWD:/workspace \
  -w /workspace \
  ghcr.io/jinalshah/devops/images/all-devops:latest \
  sh -c "
    tfswitch  # Reads .terraform-version
    terraform version
  "
```

---

## Testing Infrastructure

### Validation and Linting

```bash
#!/bin/bash
# validate.sh - Comprehensive Terraform validation

docker run --rm \
  -v $PWD:/workspace \
  -w /workspace \
  ghcr.io/jinalshah/devops/images/all-devops:latest \
  sh -c "
    # Format check
    echo '==> Checking Terraform formatting...'
    terraform fmt -check -recursive

    # Validate configuration
    echo '==> Validating Terraform configuration...'
    terraform init -backend=false
    terraform validate

    # Run TFLint
    echo '==> Running TFLint...'
    tflint --init
    tflint --recursive

    # Security scan with Trivy
    echo '==> Scanning for security issues...'
    trivy config . --severity HIGH,CRITICAL
  "
```

### Pre-commit Hooks

**`.pre-commit-config.yaml`**:

```yaml
repos:
  - repo: local
    hooks:
      - id: terraform-fmt
        name: Terraform Format
        entry: docker run --rm -v $PWD:/workspace -w /workspace ghcr.io/jinalshah/devops/images/all-devops:latest terraform fmt -check -recursive
        language: system
        files: \.tf$
        pass_filenames: false

      - id: terraform-validate
        name: Terraform Validate
        entry: docker run --rm -v $PWD:/workspace -w /workspace ghcr.io/jinalshah/devops/images/all-devops:latest sh -c "terraform init -backend=false && terraform validate"
        language: system
        files: \.tf$
        pass_filenames: false

      - id: tflint
        name: TFLint
        entry: docker run --rm -v $PWD:/workspace -w /workspace ghcr.io/jinalshah/devops/images/all-devops:latest sh -c "tflint --init && tflint"
        language: system
        files: \.tf$
        pass_filenames: false
```

**Install and run**:

```bash
# Install pre-commit
pip install pre-commit

# Install hooks
pre-commit install

# Run manually
pre-commit run --all-files
```

---

## Module Development

### Testing Terraform Modules

**Directory structure**:

```
terraform-aws-vpc/
├── main.tf
├── variables.tf
├── outputs.tf
├── README.md
└── examples/
    ├── basic/
    │   ├── main.tf
    │   └── outputs.tf
    └── advanced/
        ├── main.tf
        └── outputs.tf
```

**Test module example**:

```bash
#!/bin/bash
# test-module.sh

cd examples/basic

docker run --rm \
  -v $PWD:/workspace \
  -v ~/.aws:/root/.aws \
  -w /workspace \
  ghcr.io/jinalshah/devops/images/all-devops:latest \
  sh -c "
    # Validate example
    terraform init
    terraform validate
    terraform plan

    # Deploy for testing
    terraform apply -auto-approve

    # Run tests (if using Terratest)
    # go test -v -timeout 30m

    # Cleanup
    terraform destroy -auto-approve
  "
```

---

## Cost Estimation

### Estimate Infrastructure Costs

```bash
# Using Infracost (if installed in custom image)
docker run --rm \
  -v $PWD:/workspace \
  -w /workspace \
  ghcr.io/jinalshah/devops/images/all-devops:latest \
  sh -c "
    terraform init
    terraform plan -out=tfplan

    # Generate cost breakdown
    # infracost breakdown --path tfplan
  "
```

---

## Import Existing Resources

### Import AWS Resources

```bash
# Import existing EC2 instance
docker run --rm \
  -v $PWD:/workspace \
  -v ~/.aws:/root/.aws \
  -w /workspace \
  ghcr.io/jinalshah/devops/images/all-devops:latest \
  terraform import aws_instance.example i-1234567890abcdef0

# Import VPC
docker run --rm \
  -v $PWD:/workspace \
  -v ~/.aws:/root/.aws \
  -w /workspace \
  ghcr.io/jinalshah/devops/images/all-devops:latest \
  terraform import aws_vpc.main vpc-12345678
```

---

## Workspace Management

### Using Terraform Workspaces

```bash
docker run -it --rm \
  -v $PWD:/workspace \
  -v ~/.aws:/root/.aws \
  -w /workspace \
  ghcr.io/jinalshah/devops/images/all-devops:latest

# Inside container
terraform workspace list
terraform workspace new dev
terraform workspace new staging
terraform workspace new production

# Switch workspace
terraform workspace select dev
terraform plan

terraform workspace select production
terraform plan
```

---

## Drift Detection

### Detect Configuration Drift

```bash
#!/bin/bash
# detect-drift.sh

docker run --rm \
  -v $PWD:/workspace \
  -v ~/.aws:/root/.aws \
  -w /workspace \
  ghcr.io/jinalshah/devops/images/all-devops:latest \
  sh -c "
    terraform init
    terraform plan -detailed-exitcode
    EXIT_CODE=\$?

    if [ \$EXIT_CODE -eq 0 ]; then
      echo 'No drift detected'
    elif [ \$EXIT_CODE -eq 2 ]; then
      echo 'Drift detected! Run terraform apply to sync.'
      exit 1
    else
      echo 'Error running terraform plan'
      exit \$EXIT_CODE
    fi
  "
```

**Schedule with cron**:

```bash
# Run drift detection daily at 9am
0 9 * * * /path/to/detect-drift.sh
```

---

## AI-Assisted Terraform

### Code Generation with Claude

```bash
docker run -it --rm \
  -v $PWD:/workspace \
  -v ~/.claude:/root/.claude \
  -w /workspace \
  ghcr.io/jinalshah/devops/images/all-devops:latest

# Inside container
claude "Generate Terraform code to create an AWS VPC with 3 public and 3 private subnets across 3 availability zones" \
  > vpc.tf

# Review generated code
cat vpc.tf

# Validate
terraform init
terraform validate
```

### Infrastructure Review

```bash
docker run --rm \
  -v $PWD:/workspace \
  -v ~/.claude:/root/.claude \
  -w /workspace \
  ghcr.io/jinalshah/devops/images/all-devops:latest \
  sh -c "
    claude 'Review this Terraform code for security issues, best practices, and cost optimization' \
      --file main.tf \
      > review-report.md

    cat review-report.md
  "
```

---

## Documentation Generation

### Auto-Generate Module Docs

```bash
# Using terraform-docs (if installed in custom image)
docker run --rm \
  -v $PWD:/workspace \
  -w /workspace \
  ghcr.io/jinalshah/devops/images/all-devops:latest \
  sh -c "
    # Generate README.md
    # terraform-docs markdown table . > README.md

    # Or use Claude to generate docs
    claude 'Generate comprehensive documentation for this Terraform module' \
      --file main.tf \
      --file variables.tf \
      --file outputs.tf \
      > README.md
  "
```

---

## Best Practices

!!! tip "State Management"

    1. **Always use remote state**: Use S3, GCS, or Terraform Cloud
    2. **Enable state locking**: Prevent concurrent modifications
    3. **Encrypt state**: Enable encryption at rest
    4. **Version state files**: Use S3 versioning or equivalent
    5. **Backup state regularly**: Automated backups of state files

!!! tip "Code Organization"

    1. **Use modules**: Reusable, testable components
    2. **Separate environments**: Use workspaces or directories
    3. **Version pin providers**: Ensure reproducible deployments
    4. **Use variables**: Make code configurable
    5. **Document everything**: README, variables descriptions, outputs

!!! tip "Security"

    1. **Never commit secrets**: Use variables, Vault, or parameter stores
    2. **Scan for vulnerabilities**: Use Trivy, Checkov, or tfsec
    3. **Least privilege**: Use minimal IAM permissions
    4. **Review plans**: Always review before apply
    5. **Audit changes**: Track who deploys what

!!! warning "Common Pitfalls"

    - ❌ **No state locking**: Can lead to corrupted state
    - ❌ **Hardcoded values**: Makes code inflexible
    - ❌ **No validation**: Catch errors early with `terraform validate`
    - ❌ **Large state files**: Break into smaller modules
    - ❌ **No version pinning**: Can break on provider updates

---

## Troubleshooting

??? question "State lock timeout"

    **Problem**: DynamoDB table locked by another process

    **Solution**: Force unlock (use with caution)
    ```bash
    docker run --rm \
      -v $PWD:/workspace \
      -v ~/.aws:/root/.aws \
      -w /workspace \
      ghcr.io/jinalshah/devops/images/all-devops:latest \
      terraform force-unlock <LOCK_ID>
    ```

??? question "Provider registry unreachable"

    **Problem**: Cannot download providers

    **Solution**: Use provider mirror or cache
    ```bash
    # Create provider mirror
    mkdir -p ~/.terraform.d/plugin-cache

    docker run --rm \
      -v $PWD:/workspace \
      -v ~/.terraform.d:/root/.terraform.d \
      -w /workspace \
      ghcr.io/jinalshah/devops/images/all-devops:latest \
      terraform providers mirror ~/.terraform.d/plugin-cache
    ```

??? question "Module not found"

    **Problem**: Git-based module cannot be cloned

    **Solution**: Mount SSH keys
    ```bash
    docker run --rm \
      -v $PWD:/workspace \
      -v ~/.ssh:/root/.ssh \
      -w /workspace \
      ghcr.io/jinalshah/devops/images/all-devops:latest \
      terraform init
    ```

---

## Advanced Patterns

### Blue-Green Deployments

```hcl
# main.tf
resource "aws_instance" "blue" {
  count         = var.active_environment == "blue" ? var.instance_count : 0
  ami           = var.blue_ami
  instance_type = var.instance_type
  tags = {
    Environment = "blue"
  }
}

resource "aws_instance" "green" {
  count         = var.active_environment == "green" ? var.instance_count : 0
  ami           = var.green_ami
  instance_type = var.instance_type
  tags = {
    Environment = "green"
  }
}
```

### Canary Deployments

```hcl
# main.tf
resource "aws_instance" "stable" {
  count         = var.stable_count
  ami           = var.stable_ami
  instance_type = var.instance_type
}

resource "aws_instance" "canary" {
  count         = var.canary_count
  ami           = var.canary_ami
  instance_type = var.instance_type
}
```

---

## Next Steps

- [Multi-Tool Patterns](multi-tool-patterns.md) - Combining Terraform with Ansible, Helm
- [CI/CD Integration](ci-cd-github.md) - Automate Terraform in CI/CD
- [AI-Assisted DevOps](ai-assisted-devops.md) - Use AI for infrastructure code
- [Authentication Guide](../use-images/authentication.md) - Configure cloud credentials
