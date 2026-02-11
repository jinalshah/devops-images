# GCP DevOps Image

`gcp-devops` is optimized for GCP-centric workflows with the shared platform tooling.

## Pull

```bash
docker pull ghcr.io/jinalshah/devops/images/gcp-devops:latest
docker pull registry.gitlab.com/jinal-shah/devops/images/gcp-devops:latest
docker pull js01/gcp-devops:latest
```

## Includes

- Base toolchain:
  - Terraform, Terragrunt, TFLint, Packer
  - kubectl, Helm, k9s
  - Trivy, Ansible, ansible-lint
  - Python, Git, gh, jq, Task
  - Node.js and AI CLIs (`claude`, `codex`, `copilot`, `gemini`)
- GCP additions:
  - Google Cloud CLI (`gcloud`)
  - `docker-credential-gcr`

## Typical Commands

```bash
docker run --rm -v ~/.config/gcloud:/root/.config/gcloud ghcr.io/jinalshah/devops/images/gcp-devops:latest gcloud auth list
docker run --rm ghcr.io/jinalshah/devops/images/gcp-devops:latest gcloud components list --quiet
docker run --rm ghcr.io/jinalshah/devops/images/gcp-devops:latest kubectl version --client
```

## Best For

- GCP-first DevOps and platform teams
- CI jobs that need `gcloud` and Kubernetes tooling
- Leaner cloud-specific image than `all-devops` when AWS is not needed
