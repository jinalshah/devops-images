# Getting Started

This project publishes multi-architecture DevOps container images for daily engineering work, CI, and automation.

## Choose an Image

| Image | Use Case | Includes |
|---|---|---|
| `all-devops` | One image for mixed cloud and platform workflows | Base tools + AWS + GCP |
| `aws-devops` | AWS-focused operations and automation | Base tools + AWS |
| `gcp-devops` | GCP-focused operations and automation | Base tools + GCP |

Base tools include Terraform, Terragrunt, TFLint, Packer, kubectl, Helm, Trivy, Ansible, GitHub CLI, Task, Python, network utilities, and common shell tooling.

## Registries

All images are published to:

- GHCR: `ghcr.io/jinalshah/devops/images/<image>:<tag>`
- GitLab: `registry.gitlab.com/jinal-shah/devops/images/<image>:<tag>`
- Docker Hub: `js01/<image>:<tag>`

`<image>` is `all-devops`, `aws-devops`, or `gcp-devops`.

## Quick Start

```bash
docker pull ghcr.io/jinalshah/devops/images/all-devops:latest
```

```bash
docker run -it --name devops-images \
  -v $PWD:/srv \
  -v ~/.ssh:/root/.ssh \
  -v ~/.aws:/root/.aws \
  -v ~/.claude:/root/.claude \
  -v ~/.codex:/root/.codex \
  -v ~/.copilot:/root/.copilot \
  -v ~/.gemini:/root/.gemini \
  ghcr.io/jinalshah/devops/images/all-devops:latest
```

## Tag and Platform Model

The CI pipeline publishes:

- Multi-arch tags for `linux/amd64` and `linux/arm64`
- Immutable version tags in the form `1.0.<sha7>`
- Arch-specific tags such as `1.0.<sha7>-amd64` and `1.0.<sha7>-arm64`
- `latest` only when the workflow runs on the `main` branch

For reproducible automation, pin to a version tag instead of `latest`.

## Paths Through the Docs

- New users: start with [Using the Images](use-images/index.md)
- Build and customization users: go to [Building Images](build-images/index.md)
- Advanced build and publishing workflows: see [Multi-platform Images](build-images/multi-platform-images.md)
- Tool usage reference: see [Tool Basics](tool-basics/index.md)
- Debugging problems: see [Troubleshooting](troubleshooting/index.md)
