# CircleCI Integration

Complete guide to using DevOps Images in CircleCI pipelines for automated infrastructure deployment, testing, and validation.

!!! tip "Why CircleCI?"
    - Cloud-hosted or self-hosted options
    - Powerful workflow orchestration
    - Docker layer caching included in paid plans
    - Generous free tier (6,000 build minutes/month)

---

## Basic Setup

### Simple Terraform Deployment

Deploy infrastructure on every push to main:

```yaml
version: 2.1

jobs:
  deploy:
    docker:
      - image: ghcr.io/jinalshah/devops/images/all-devops:1.0.abc1234  # (1)!
    steps:
      - checkout  # (2)!

      - run:
          name: Terraform Init
          command: terraform init

      - run:
          name: Terraform Apply
          command: terraform apply -auto-approve
          environment:  # (3)!
            AWS_ACCESS_KEY_ID: ${AWS_ACCESS_KEY_ID}
            AWS_SECRET_ACCESS_KEY: ${AWS_SECRET_ACCESS_KEY}
            AWS_DEFAULT_REGION: us-east-1

workflows:
  deploy-infrastructure:
    jobs:
      - deploy:
          filters:  # (4)!
            branches:
              only: main
```

1. Use DevOps Image as executor
2. Check out code from repository
3. Set environment variables from CircleCI context
4. Only run on main branch

---

## Multi-Stage Pipeline

### Validate → Plan → Apply

```yaml
version: 2.1

executors:
  devops-executor:
    docker:
      - image: ghcr.io/jinalshah/devops/images/all-devops:1.0.abc1234

jobs:
  validate:
    executor: devops-executor
    steps:
      - checkout

      - run:
          name: Terraform Format Check
          command: terraform fmt -check -recursive

      - run:
          name: TFLint
          command: |
            cd terraform
            tflint --init
            tflint

      - run:
          name: Trivy Scan
          command: |
            trivy config ./terraform \
              --severity HIGH,CRITICAL \
              --exit-code 1

  plan:
    executor: devops-executor
    steps:
      - checkout

      - run:
          name: Terraform Plan
          command: |
            cd terraform
            terraform init
            terraform plan -out=tfplan

      - persist_to_workspace:  # (1)!
          root: terraform
          paths:
            - tfplan
            - .terraform

  apply:
    executor: devops-executor
    steps:
      - checkout

      - attach_workspace:  # (2)!
          at: terraform

      - run:
          name: Terraform Apply
          command: |
            cd terraform
            terraform init
            terraform apply tfplan

workflows:
  terraform-pipeline:
    jobs:
      - validate
      - plan:
          requires:
            - validate
      - hold-for-approval:  # (3)!
          type: approval
          requires:
            - plan
          filters:
            branches:
              only: main
      - apply:
          requires:
            - hold-for-approval
```

1. Save plan artifact to workspace
2. Restore plan artifact from workspace
3. Manual approval gate for production

---

## Multi-Cloud Deployment

### Deploy to Both AWS and GCP

```yaml
version: 2.1

executors:
  devops-executor:
    docker:
      - image: ghcr.io/jinalshah/devops/images/all-devops:1.0.abc1234

jobs:
  deploy-aws:
    executor: devops-executor
    steps:
      - checkout

      - run:
          name: Deploy AWS Infrastructure
          command: |
            cd terraform/aws
            terraform init
            terraform apply -auto-approve
          environment:
            AWS_ACCESS_KEY_ID: ${AWS_ACCESS_KEY_ID}
            AWS_SECRET_ACCESS_KEY: ${AWS_SECRET_ACCESS_KEY}
            AWS_DEFAULT_REGION: us-east-1

  deploy-gcp:
    executor: devops-executor
    steps:
      - checkout

      - run:
          name: Setup GCP Credentials
          command: |
            echo $GCP_SA_KEY | base64 -d > /tmp/gcp-key.json
            export GOOGLE_APPLICATION_CREDENTIALS=/tmp/gcp-key.json

      - run:
          name: Deploy GCP Infrastructure
          command: |
            cd terraform/gcp
            terraform init
            terraform apply -auto-approve

workflows:
  multi-cloud-deploy:
    jobs:
      - deploy-aws:
          context: aws-production  # (1)!
          filters:
            branches:
              only: main
      - deploy-gcp:
          context: gcp-production  # (2)!
          filters:
            branches:
              only: main
```

1. Use CircleCI context for AWS credentials
2. Use CircleCI context for GCP credentials

---

## Matrix Builds

### Deploy to Multiple Environments

```yaml
version: 2.1

executors:
  devops-executor:
    docker:
      - image: ghcr.io/jinalshah/devops/images/all-devops:1.0.abc1234
    environment:
      TF_DIR: terraform/<< parameters.cloud >>/<< parameters.environment >>

parameters:
  cloud:
    type: string
  environment:
    type: string

jobs:
  deploy:
    executor: devops-executor
    parameters:
      cloud:
        type: string
      environment:
        type: string
    steps:
      - checkout

      - run:
          name: Deploy << parameters.cloud >> << parameters.environment >>
          command: |
            cd terraform/<< parameters.cloud >>/<< parameters.environment >>
            terraform init
            terraform apply -auto-approve

workflows:
  deploy-all-environments:
    jobs:
      # AWS environments
      - deploy:
          name: deploy-aws-dev
          cloud: aws
          environment: dev
          context: aws-dev

      - deploy:
          name: deploy-aws-staging
          cloud: aws
          environment: staging
          context: aws-staging
          requires:
            - deploy-aws-dev

      - deploy:
          name: deploy-aws-prod
          cloud: aws
          environment: production
          context: aws-production
          requires:
            - deploy-aws-staging

      # GCP environments
      - deploy:
          name: deploy-gcp-dev
          cloud: gcp
          environment: dev
          context: gcp-dev

      - deploy:
          name: deploy-gcp-staging
          cloud: gcp
          environment: staging
          context: gcp-staging
          requires:
            - deploy-gcp-dev
```

---

## Security Scanning Pipeline

### Comprehensive Security Checks

```yaml
version: 2.1

executors:
  devops-executor:
    docker:
      - image: ghcr.io/jinalshah/devops/images/all-devops:1.0.abc1234

jobs:
  trivy-scan:
    executor: devops-executor
    steps:
      - checkout

      - run:
          name: Trivy IaC Scan
          command: |
            trivy config ./terraform \
              --format json \
              --output trivy-report.json
            trivy config ./terraform \
              --severity HIGH,CRITICAL

      - store_artifacts:  # (1)!
          path: trivy-report.json

  tflint:
    executor: devops-executor
    steps:
      - checkout

      - run:
          name: TFLint
          command: |
            cd terraform
            tflint --init
            tflint --minimum-failure-severity=error

  cfn-lint:
    executor: devops-executor
    steps:
      - checkout

      - run:
          name: CloudFormation Lint
          command: cfn-lint cloudformation/**/*.yaml

  ansible-lint:
    executor: devops-executor
    steps:
      - checkout

      - run:
          name: Ansible Lint
          command: ansible-lint ansible/

workflows:
  security-scan:
    jobs:
      - trivy-scan
      - tflint
      - cfn-lint
      - ansible-lint
```

1. Store scan results as CircleCI artifacts

---

## Kubernetes Deployment

### Deploy to EKS/GKE with Helm

```yaml
version: 2.1

executors:
  devops-executor:
    docker:
      - image: ghcr.io/jinalshah/devops/images/all-devops:1.0.abc1234

jobs:
  deploy-eks:
    executor: devops-executor
    steps:
      - checkout

      - run:
          name: Configure kubectl for EKS
          command: |
            aws eks update-kubeconfig \
              --region us-east-1 \
              --name my-eks-cluster
          environment:
            AWS_ACCESS_KEY_ID: ${AWS_ACCESS_KEY_ID}
            AWS_SECRET_ACCESS_KEY: ${AWS_SECRET_ACCESS_KEY}

      - run:
          name: Deploy with Helm
          command: |
            helm upgrade --install myapp ./charts/myapp \
              --namespace production \
              --create-namespace \
              --set image.tag=${CIRCLE_SHA1:0:7} \
              --wait \
              --timeout 5m

      - run:
          name: Verify Deployment
          command: |
            kubectl rollout status deployment/myapp -n production
            kubectl get pods -n production

workflows:
  k8s-deploy:
    jobs:
      - deploy-eks:
          context: aws-production
          filters:
            branches:
              only: main
```

---

## Docker Layer Caching

### Speed Up Builds with DLC

```yaml
version: 2.1

executors:
  devops-executor:
    docker:
      - image: ghcr.io/jinalshah/devops/images/all-devops:1.0.abc1234

jobs:
  build-and-deploy:
    executor: devops-executor
    steps:
      - checkout
      - setup_remote_docker:  # (1)!
          docker_layer_caching: true  # (2)!

      - run:
          name: Build Docker Image
          command: docker build -t myapp:${CIRCLE_SHA1} .

      - run:
          name: Push to Registry
          command: |
            echo $DOCKER_PASSWORD | docker login -u $DOCKER_USERNAME --password-stdin
            docker push myapp:${CIRCLE_SHA1}

workflows:
  build-deploy:
    jobs:
      - build-and-deploy
```

1. Enable remote Docker for building images
2. Enable Docker Layer Caching (requires paid plan)

---

## Orbs Integration

### Using CircleCI Orbs with DevOps Images

```yaml
version: 2.1

orbs:
  aws-cli: circleci/aws-cli@4.0  # (1)!
  slack: circleci/slack@4.12

executors:
  devops-executor:
    docker:
      - image: ghcr.io/jinalshah/devops/images/all-devops:1.0.abc1234

jobs:
  deploy:
    executor: devops-executor
    steps:
      - checkout

      - aws-cli/setup:  # (2)!
          profile_name: default

      - run:
          name: Terraform Apply
          command: |
            terraform init
            terraform apply -auto-approve

      - slack/notify:  # (3)!
          event: pass
          template: success_tagged_deploy_1

      - slack/notify:
          event: fail
          template: basic_fail_1

workflows:
  deploy-with-notifications:
    jobs:
      - deploy:
          context:
            - aws-production
            - slack
```

1. Import CircleCI orbs for common tasks
2. Use AWS CLI orb to configure credentials
3. Send Slack notifications on success/failure

---

## AI-Assisted Code Review

### Automated Review with Claude CLI

```yaml
version: 2.1

executors:
  devops-executor:
    docker:
      - image: ghcr.io/jinalshah/devops/images/all-devops:1.0.abc1234

jobs:
  ai-review:
    executor: devops-executor
    steps:
      - checkout

      - run:
          name: Setup Claude CLI
          command: |
            mkdir -p ~/.claude
            echo "${CLAUDE_API_KEY}" > ~/.claude/config.json

      - run:
          name: Review Terraform Changes
          command: |
            git diff origin/main...HEAD -- terraform/ > changes.diff
            claude "Review this Terraform code for security issues and best practices" \
              --file changes.diff \
              > review-output.md

      - store_artifacts:
          path: review-output.md

      - run:
          name: Post Review to PR
          command: |
            # Post to GitHub PR comment
            curl -X POST \
              -H "Authorization: token ${GITHUB_TOKEN}" \
              -d "{\"body\": \"$(cat review-output.md)\"}" \
              https://api.github.com/repos/${CIRCLE_PROJECT_USERNAME}/${CIRCLE_PROJECT_REPONAME}/issues/${CIRCLE_PULL_REQUEST##*/}/comments

workflows:
  pr-review:
    jobs:
      - ai-review:
          filters:
            branches:
              ignore: main
```

---

## Best Practices

!!! tip "Performance Optimization"

    1. **Use executors**: Define reusable executors to avoid repetition
    2. **Enable DLC**: Docker Layer Caching speeds up image pulls (paid feature)
    3. **Cache dependencies**: Cache Terraform plugins and modules
    4. **Parallel jobs**: Run independent jobs in parallel
    5. **Use workspaces**: Share data between jobs efficiently

!!! tip "Security Best Practices"

    1. **Use Contexts**: Store secrets in CircleCI contexts
    2. **Limit context access**: Restrict contexts to specific teams/projects
    3. **Use approval jobs**: Add manual gates for production deployments
    4. **Rotate secrets**: Regularly rotate credentials stored in contexts
    5. **Audit logs**: Review CircleCI audit logs regularly

!!! warning "Common Pitfalls"

    - ❌ **Using `latest` tag**: Non-reproducible builds
    - ❌ **Hardcoding secrets**: Always use CircleCI contexts or environment variables
    - ❌ **No resource classes**: Can lead to slow builds (upgrade to larger resource class)
    - ❌ **Ignoring artifacts**: Store important files for debugging

---

## Resource Classes

### Optimize Build Performance

```yaml
version: 2.1

executors:
  small-executor:
    docker:
      - image: ghcr.io/jinalshah/devops/images/all-devops:1.0.abc1234
    resource_class: small  # 1 vCPU, 2GB RAM

  medium-executor:
    docker:
      - image: ghcr.io/jinalshah/devops/images/all-devops:1.0.abc1234
    resource_class: medium  # 2 vCPUs, 4GB RAM

  large-executor:
    docker:
      - image: ghcr.io/jinalshah/devops/images/all-devops:1.0.abc1234
    resource_class: large  # 4 vCPUs, 8GB RAM

jobs:
  lint:
    executor: small-executor  # Fast linting doesn't need resources
    steps:
      - checkout
      - run: terraform fmt -check

  deploy:
    executor: large-executor  # Complex deployments benefit from resources
    steps:
      - checkout
      - run: terraform apply -auto-approve
```

---

## Troubleshooting

??? question "Image pull rate limited"

    **Problem**: Docker Hub rate limits exceeded

    **Solution**: Use GHCR or authenticate with Docker Hub
    ```yaml
    - run:
        name: Login to Docker Hub
        command: echo $DOCKER_PASSWORD | docker login -u $DOCKER_USERNAME --password-stdin
    ```

??? question "Workspace not persisting"

    **Problem**: Files not available in downstream jobs

    **Solution**: Use `persist_to_workspace` and `attach_workspace`
    ```yaml
    # In first job
    - persist_to_workspace:
        root: .
        paths:
          - terraform/tfplan

    # In second job
    - attach_workspace:
        at: .
    ```

??? question "Environment variables not set"

    **Problem**: Variables from context not accessible

    **Solution**: Ensure job uses correct context
    ```yaml
    workflows:
      deploy:
        jobs:
          - deploy-job:
              context: production  # Make sure context is specified
    ```

---

## Example Repository Structure

```
.
├── .circleci/
│   └── config.yml
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
- [GitLab CI Integration](ci-cd-gitlab.md) - GitLab CI examples
- [Jenkins Integration](ci-cd-jenkins.md) - Jenkins pipeline examples
- [AI-Assisted DevOps](ai-assisted-devops.md) - AI workflow automation
- [Multi-Tool Patterns](multi-tool-patterns.md) - Combining multiple tools
