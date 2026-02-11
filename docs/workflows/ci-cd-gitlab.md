# GitLab CI/CD Integration

Complete guide to using DevOps Images in GitLab CI pipelines for automated infrastructure deployment, testing, and validation.

!!! tip "Why GitLab CI?"
    - Native GitLab integration
    - GitLab Container Registry optimized for CI
    - Generous free tier (400 minutes/month for free tier)
    - Built-in security scanning and compliance features

---

## Basic Setup

### Simple Terraform Deployment

Deploy infrastructure on every push to main:

```yaml
stages:
  - deploy

deploy:production:
  stage: deploy
  image: registry.gitlab.com/jinal-shah/devops/images/all-devops:1.0.abc1234  # (1)!
  script:
    - terraform init
    - terraform apply -auto-approve
  variables:
    AWS_ACCESS_KEY_ID: $AWS_ACCESS_KEY_ID  # (2)!
    AWS_SECRET_ACCESS_KEY: $AWS_SECRET_ACCESS_KEY
    AWS_DEFAULT_REGION: us-east-1
  only:
    - main  # (3)!
```

1. Use GitLab Container Registry for faster pulls in GitLab CI
2. Use GitLab CI/CD variables (Settings → CI/CD → Variables)
3. Only run on main branch

---

## Multi-Stage Pipeline

### Validate → Plan → Apply

Comprehensive pipeline with validation, planning, and conditional deployment:

```yaml
stages:
  - validate
  - plan
  - apply

variables:
  TF_ROOT: ${CI_PROJECT_DIR}/terraform  # (1)!
  TF_STATE_NAME: default

cache:  # (2)!
  paths:
    - ${TF_ROOT}/.terraform

# Validate Stage
terraform:validate:
  stage: validate
  image: registry.gitlab.com/jinal-shah/devops/images/all-devops:1.0.abc1234
  script:
    - cd ${TF_ROOT}
    - terraform fmt -check -recursive
    - terraform init -backend=false
    - terraform validate

tflint:
  stage: validate
  image: registry.gitlab.com/jinal-shah/devops/images/all-devops:1.0.abc1234
  script:
    - cd ${TF_ROOT}
    - tflint --init
    - tflint

trivy:scan:
  stage: validate
  image: registry.gitlab.com/jinal-shah/devops/images/all-devops:1.0.abc1234
  script:
    - trivy config ${TF_ROOT} --exit-code 1 --severity HIGH,CRITICAL
  allow_failure: true  # (3)!

# Plan Stage
terraform:plan:
  stage: plan
  image: registry.gitlab.com/jinal-shah/devops/images/all-devops:1.0.abc1234
  script:
    - cd ${TF_ROOT}
    - terraform init
    - terraform plan -out=tfplan
  artifacts:  # (4)!
    paths:
      - ${TF_ROOT}/tfplan
    expire_in: 1 day
  variables:
    AWS_ACCESS_KEY_ID: $AWS_ACCESS_KEY_ID
    AWS_SECRET_ACCESS_KEY: $AWS_SECRET_ACCESS_KEY
    AWS_DEFAULT_REGION: us-east-1
  only:
    - merge_requests
    - main

# Apply Stage
terraform:apply:
  stage: apply
  image: registry.gitlab.com/jinal-shah/devops/images/all-devops:1.0.abc1234
  script:
    - cd ${TF_ROOT}
    - terraform init
    - terraform apply tfplan
  dependencies:
    - terraform:plan
  variables:
    AWS_ACCESS_KEY_ID: $AWS_ACCESS_KEY_ID
    AWS_SECRET_ACCESS_KEY: $AWS_SECRET_ACCESS_KEY
    AWS_DEFAULT_REGION: us-east-1
  environment:  # (5)!
    name: production
    action: start
  when: manual  # (6)!
  only:
    - main
```

1. Define common variables for reuse
2. Cache Terraform plugins for faster builds
3. Allow vulnerability scans to fail without blocking pipeline
4. Save plan as artifact for apply stage
5. Track deployments in GitLab Environments
6. Require manual approval for production deployments

---

## Multi-Cloud Deployment

### Deploy to Both AWS and GCP

```yaml
stages:
  - deploy-aws
  - deploy-gcp

deploy:aws:
  stage: deploy-aws
  image: registry.gitlab.com/jinal-shah/devops/images/all-devops:1.0.abc1234
  script:
    - cd terraform/aws
    - terraform init
    - terraform apply -auto-approve
  variables:
    AWS_ACCESS_KEY_ID: $AWS_ACCESS_KEY_ID
    AWS_SECRET_ACCESS_KEY: $AWS_SECRET_ACCESS_KEY
    AWS_DEFAULT_REGION: us-east-1
  environment:
    name: aws-production
  only:
    - main

deploy:gcp:
  stage: deploy-gcp
  image: registry.gitlab.com/jinal-shah/devops/images/all-devops:1.0.abc1234
  before_script:
    - echo $GCP_SA_KEY | base64 -d > /tmp/gcp-key.json  # (1)!
    - export GOOGLE_APPLICATION_CREDENTIALS=/tmp/gcp-key.json
  script:
    - cd terraform/gcp
    - terraform init
    - terraform apply -auto-approve
  after_script:
    - rm -f /tmp/gcp-key.json  # (2)!
  environment:
    name: gcp-production
  only:
    - main
```

1. Decode base64-encoded service account key from GitLab variable
2. Clean up sensitive files after deployment

---

## Parallel Matrix Builds

### Deploy to Multiple Environments

```yaml
stages:
  - deploy

.deploy_template: &deploy_template  # (1)!
  image: registry.gitlab.com/jinal-shah/devops/images/all-devops:1.0.abc1234
  script:
    - cd terraform/${CLOUD}/${ENVIRONMENT}
    - terraform init
    - terraform apply -auto-approve
  only:
    - main

deploy:aws-dev:
  <<: *deploy_template
  variables:
    CLOUD: aws
    ENVIRONMENT: dev
    AWS_ACCESS_KEY_ID: $AWS_ACCESS_KEY_ID
    AWS_SECRET_ACCESS_KEY: $AWS_SECRET_ACCESS_KEY
  environment:
    name: aws-dev

deploy:aws-staging:
  <<: *deploy_template
  variables:
    CLOUD: aws
    ENVIRONMENT: staging
    AWS_ACCESS_KEY_ID: $AWS_ACCESS_KEY_ID
    AWS_SECRET_ACCESS_KEY: $AWS_SECRET_ACCESS_KEY
  environment:
    name: aws-staging

deploy:gcp-dev:
  <<: *deploy_template
  before_script:
    - echo $GCP_SA_KEY | base64 -d > /tmp/gcp-key.json
    - export GOOGLE_APPLICATION_CREDENTIALS=/tmp/gcp-key.json
  variables:
    CLOUD: gcp
    ENVIRONMENT: dev
  environment:
    name: gcp-dev
```

1. Use YAML anchors to avoid repetition

---

## Security Scanning Pipeline

### Comprehensive Security Checks

```yaml
stages:
  - security

security:trivy:
  stage: security
  image: registry.gitlab.com/jinal-shah/devops/images/all-devops:1.0.abc1234
  script:
    - trivy config ./terraform --format json --output trivy-report.json
    - trivy config ./terraform --severity HIGH,CRITICAL
  artifacts:
    reports:
      container_scanning: trivy-report.json  # (1)!
    paths:
      - trivy-report.json
    expire_in: 30 days

security:tflint:
  stage: security
  image: registry.gitlab.com/jinal-shah/devops/images/all-devops:1.0.abc1234
  script:
    - cd terraform
    - tflint --init
    - tflint --format junit > tflint-report.xml
  artifacts:
    reports:
      junit: terraform/tflint-report.xml

security:cfn-lint:
  stage: security
  image: registry.gitlab.com/jinal-shah/devops/images/all-devops:1.0.abc1234
  script:
    - cfn-lint cloudformation/**/*.yaml
  only:
    changes:
      - cloudformation/**/*.yaml

security:ansible-lint:
  stage: security
  image: registry.gitlab.com/jinal-shah/devops/images/all-devops:1.0.abc1234
  script:
    - ansible-lint ansible/
  only:
    changes:
      - ansible/**/*.yml
```

1. GitLab displays security reports in merge requests

---

## Kubernetes Deployment

### Deploy to EKS/GKE with Helm

```yaml
stages:
  - deploy

deploy:eks:
  stage: deploy
  image: registry.gitlab.com/jinal-shah/devops/images/all-devops:1.0.abc1234
  script:
    # Configure kubectl
    - aws eks update-kubeconfig --region us-east-1 --name my-eks-cluster

    # Deploy with Helm
    - |
      helm upgrade --install myapp ./charts/myapp \
        --namespace production \
        --create-namespace \
        --set image.tag=${CI_COMMIT_SHORT_SHA} \
        --wait \
        --timeout 5m

    # Verify deployment
    - kubectl rollout status deployment/myapp -n production
    - kubectl get pods -n production
  variables:
    AWS_ACCESS_KEY_ID: $AWS_ACCESS_KEY_ID
    AWS_SECRET_ACCESS_KEY: $AWS_SECRET_ACCESS_KEY
    AWS_DEFAULT_REGION: us-east-1
  environment:
    name: eks-production
    kubernetes:  # (1)!
      namespace: production
  only:
    - main
```

1. GitLab tracks Kubernetes deployments in the environment page

---

## Child Pipelines

### Modular Pipeline Architecture

**Main `.gitlab-ci.yml`**:

```yaml
stages:
  - trigger

trigger:terraform:
  stage: trigger
  trigger:
    include: .gitlab/ci/terraform-pipeline.yml
    strategy: depend  # (1)!
  only:
    changes:
      - terraform/**

trigger:ansible:
  stage: trigger
  trigger:
    include: .gitlab/ci/ansible-pipeline.yml
    strategy: depend
  only:
    changes:
      - ansible/**
```

1. Wait for child pipeline to complete before continuing

**`.gitlab/ci/terraform-pipeline.yml`**:

```yaml
stages:
  - validate
  - deploy

validate:
  stage: validate
  image: registry.gitlab.com/jinal-shah/devops/images/all-devops:1.0.abc1234
  script:
    - terraform fmt -check
    - terraform validate

deploy:
  stage: deploy
  image: registry.gitlab.com/jinal-shah/devops/images/all-devops:1.0.abc1234
  script:
    - terraform init
    - terraform apply -auto-approve
  when: manual
```

---

## AI-Assisted Code Review

### Automated Review with Claude CLI

```yaml
stages:
  - review

ai:review:
  stage: review
  image: registry.gitlab.com/jinal-shah/devops/images/all-devops:1.0.abc1234
  before_script:
    - mkdir -p ~/.claude
    - echo "$CLAUDE_API_KEY" > ~/.claude/config.json
  script:
    # Get diff from merge request
    - git diff origin/${CI_MERGE_REQUEST_TARGET_BRANCH_NAME}...HEAD -- terraform/ > changes.diff

    # Review with Claude
    - |
      claude "Review this Terraform code for security issues and best practices" \
        --file changes.diff \
        > review-output.md

    # Post comment to MR
    - |
      curl --request POST \
        --header "PRIVATE-TOKEN: ${CI_JOB_TOKEN}" \
        --data "body=$(cat review-output.md)" \
        "${CI_API_V4_URL}/projects/${CI_PROJECT_ID}/merge_requests/${CI_MERGE_REQUEST_IID}/notes"
  only:
    - merge_requests
```

---

## GitLab AutoDevOps Integration

### Extend AutoDevOps with Custom Tools

```yaml
include:
  - template: Auto-DevOps.gitlab-ci.yml

variables:
  AUTO_DEVOPS_IMAGE: registry.gitlab.com/jinal-shah/devops/images/all-devops:1.0.abc1234

# Override default test job
test:
  extends: .auto-devops
  image: $AUTO_DEVOPS_IMAGE
  script:
    - terraform validate
    - trivy config .
    - tflint

# Add custom infrastructure deployment
deploy:infrastructure:
  stage: deploy
  image: $AUTO_DEVOPS_IMAGE
  script:
    - terraform init
    - terraform apply -auto-approve
  environment:
    name: production
  when: manual
  only:
    - main
```

---

## Best Practices

!!! tip "Performance Optimization"

    1. **Use GitLab Container Registry**: Faster pulls in GitLab CI
    2. **Cache Terraform plugins**: Use `cache:` directive
    3. **Pin image versions**: Use immutable tags
    4. **Parallel jobs**: Use `parallel:` keyword for matrix builds
    5. **Optimize artifacts**: Only save necessary files

!!! tip "Security Best Practices"

    1. **Use CI/CD Variables**: Store secrets in project/group variables
    2. **Protected variables**: Mark sensitive variables as protected
    3. **Masked variables**: Hide secret values in job logs
    4. **Use environments**: Add approval gates for production
    5. **SAST scanning**: Enable GitLab SAST for security scanning

!!! warning "Common Pitfalls"

    - ❌ **Using `latest` tag**: Non-reproducible builds
    - ❌ **Hardcoding secrets**: Always use CI/CD variables
    - ❌ **No manual gates**: Use `when: manual` for production
    - ❌ **Ignoring cache**: Slow builds without caching

---

## GitLab-Specific Features

### Container Scanning

```yaml
include:
  - template: Security/Container-Scanning.gitlab-ci.yml

container_scanning:
  variables:
    CS_IMAGE: registry.gitlab.com/jinal-shah/devops/images/all-devops:1.0.abc1234
```

### Dependency Scanning

```yaml
include:
  - template: Security/Dependency-Scanning.gitlab-ci.yml

dependency_scanning:
  image: registry.gitlab.com/jinal-shah/devops/images/all-devops:1.0.abc1234
```

### SAST (Static Application Security Testing)

```yaml
include:
  - template: Security/SAST.gitlab-ci.yml

sast:
  image: registry.gitlab.com/jinal-shah/devops/images/all-devops:1.0.abc1234
```

---

## Troubleshooting

??? question "Image pull fails"

    **Problem**: GitLab CI can't pull the container image

    **Solutions**:
    ```yaml
    # 1. Verify image path for GitLab registry
    image: registry.gitlab.com/jinal-shah/devops/images/all-devops:1.0.abc1234

    # 2. For private images, ensure CI_JOB_TOKEN has access
    before_script:
      - docker login -u $CI_REGISTRY_USER -p $CI_JOB_TOKEN $CI_REGISTRY
    ```

??? question "Terraform state locking conflicts"

    **Problem**: Multiple jobs access Terraform state simultaneously

    **Solution**: Use `resource_group` to serialize jobs
    ```yaml
    terraform:apply:
      resource_group: terraform-state
      script:
        - terraform apply -auto-approve
    ```

??? question "Variables not available"

    **Problem**: CI/CD variables not accessible in job

    **Solutions**:
    1. Verify variable is not marked as "protected" if running on non-protected branch
    2. Check variable scope (project vs. group vs. instance)
    3. Ensure variable key name matches exactly (case-sensitive)

---

## Example Repository Structure

```
.
├── .gitlab-ci.yml
├── .gitlab/
│   └── ci/
│       ├── terraform-pipeline.yml
│       ├── ansible-pipeline.yml
│       └── k8s-pipeline.yml
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

- [GitHub Actions Integration](ci-cd-github.md) - GitHub Actions examples
- [Jenkins Integration](ci-cd-jenkins.md) - Jenkins pipeline examples
- [CircleCI Integration](ci-cd-circleci.md) - CircleCI config examples
- [AI-Assisted DevOps](ai-assisted-devops.md) - AI workflow automation
- [Multi-Tool Patterns](multi-tool-patterns.md) - Combining multiple tools
