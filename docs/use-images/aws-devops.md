# AWS DevOps Image

`aws-devops` is optimized for AWS-centric workflows while keeping the shared platform tools.

## Pull

```bash
docker pull ghcr.io/jinalshah/devops/images/aws-devops:latest
docker pull registry.gitlab.com/jinal-shah/devops/images/aws-devops:latest
docker pull js01/aws-devops:latest
```

## Includes

- Base toolchain:
  - Terraform, Terragrunt, TFLint, Packer
  - kubectl, Helm, k9s
  - Trivy, Ansible, ansible-lint
  - Python, Git, gh, jq, Task
  - Node.js and AI CLIs (`claude`, `codex`, `copilot`, `gemini`)
- AWS additions:
  - AWS CLI v2
  - Session Manager plugin
  - Python libraries for AWS automation (`boto3`, `cfn-lint`, `s3cmd`, `crcmod`)

## Typical Commands

```bash
docker run --rm -v ~/.aws:/root/.aws ghcr.io/jinalshah/devops/images/aws-devops:latest aws sts get-caller-identity
docker run --rm ghcr.io/jinalshah/devops/images/aws-devops:latest cfn-lint --version
docker run --rm ghcr.io/jinalshah/devops/images/aws-devops:latest terragrunt --version
```

## Best For

- AWS-first DevOps and SRE teams
- CI jobs that do not require `gcloud`
- Faster startup than the full multi-cloud image in AWS-only pipelines
