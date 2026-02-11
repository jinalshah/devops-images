# DevOps Images

[![Build and Push](https://github.com/jinalshah/devops-images/actions/workflows/image-builder.yml/badge.svg)](https://github.com/jinalshah/devops-images/actions/workflows/image-builder.yml)

Container images with a curated DevOps toolchain for AWS, GCP, and general platform engineering workflows.

## Images

- `all-devops`: Base tools + AWS + GCP CLIs
- `aws-devops`: Base tools + AWS tooling
- `gcp-devops`: Base tools + GCP tooling

## Registries

- GitHub Container Registry (GHCR): `ghcr.io/jinalshah/devops/images/<image>:<tag>`
- GitLab Container Registry: `registry.gitlab.com/jinal-shah/devops/images/<image>:<tag>`
- Docker Hub: `js01/<image>:<tag>`

`<image>` is one of `all-devops`, `aws-devops`, or `gcp-devops`.

## Quick Start

```bash
docker pull ghcr.io/jinalshah/devops/images/all-devops:latest

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

## Build Locally

```bash
# Specific image
docker build --target aws-devops -t aws-devops:local .

# All images
for target in all-devops aws-devops gcp-devops; do
  docker build --target "$target" -t "$target:local" .
done
```

## Documentation

- Published docs: [https://jinalshah.github.io/devops-images/](https://jinalshah.github.io/devops-images/)
- Local docs preview:

```bash
python3 -m pip install --upgrade mkdocs-material
mkdocs serve
```

Open [http://localhost:8000](http://localhost:8000).
