# All DevOps Image

`all-devops` is the full toolkit image for teams that touch both AWS and GCP.

## Pull

```bash
docker pull ghcr.io/jinalshah/devops/images/all-devops:latest
docker pull registry.gitlab.com/jinal-shah/devops/images/all-devops:latest
docker pull js01/all-devops:latest
```

## Includes

- Everything from the base stage:
  - Terraform, Terragrunt, TFLint, Packer
  - kubectl, Helm, k9s
  - Trivy
  - Ansible and ansible-lint
  - gh CLI and ghorg
  - Node.js LTS, npm, and AI CLIs (`claude`, `codex`, `copilot`, `gemini`)
  - Python, Git, jq, network tools, DB clients (`mongosh`, `psql`, `mysql`)
- AWS tools:
  - AWS CLI v2
  - Session Manager plugin
  - AWS-focused Python packages (`boto3`, `cfn-lint`, `s3cmd`, and others)
- GCP tools:
  - Google Cloud CLI (`gcloud`)
  - `docker-credential-gcr` component

## Typical Commands

```bash
docker run --rm ghcr.io/jinalshah/devops/images/all-devops:latest terraform version
docker run --rm ghcr.io/jinalshah/devops/images/all-devops:latest aws --version
docker run --rm ghcr.io/jinalshah/devops/images/all-devops:latest gcloud --version
docker run --rm ghcr.io/jinalshah/devops/images/all-devops:latest trivy --version
```

## Best For

- Platform teams managing multi-cloud infrastructure
- CI images that need one consistent, broad toolchain
- Local environments where you do not want to install tools directly on the host
