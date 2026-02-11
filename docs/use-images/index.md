# Using the Images

This section covers pull, run, and automation patterns from beginner to advanced usage.

## Image and Registry Reference

| Image | GHCR | GitLab | Docker Hub |
|---|---|---|---|
| All DevOps | `ghcr.io/jinalshah/devops/images/all-devops` | `registry.gitlab.com/jinal-shah/devops/images/all-devops` | `js01/all-devops` |
| AWS DevOps | `ghcr.io/jinalshah/devops/images/aws-devops` | `registry.gitlab.com/jinal-shah/devops/images/aws-devops` | `js01/aws-devops` |
| GCP DevOps | `ghcr.io/jinalshah/devops/images/gcp-devops` | `registry.gitlab.com/jinal-shah/devops/images/gcp-devops` | `js01/gcp-devops` |

## Pull an Image

```bash
# GHCR
docker pull ghcr.io/jinalshah/devops/images/all-devops:latest

# GitLab
docker pull registry.gitlab.com/jinal-shah/devops/images/all-devops:latest

# Docker Hub
docker pull js01/all-devops:latest
```

## Run Interactively

```bash
docker run -it --rm ghcr.io/jinalshah/devops/images/all-devops:latest
```

The default shell is `zsh`.

## Recommended Workstation Run Command

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

If you use GCP, also mount `~/.config/gcloud:/root/.config/gcloud`.

## Run Tools Without an Interactive Shell

```bash
docker run --rm ghcr.io/jinalshah/devops/images/all-devops:latest terraform version
docker run --rm ghcr.io/jinalshah/devops/images/aws-devops:latest aws --version
docker run --rm ghcr.io/jinalshah/devops/images/gcp-devops:latest gcloud --version
docker run --rm ghcr.io/jinalshah/devops/images/all-devops:latest trivy --version
```

## Work With Local Files

```bash
docker run --rm -v "$PWD":/srv ghcr.io/jinalshah/devops/images/all-devops:latest \
  ansible-playbook /srv/playbook.yml
```

To avoid root-owned files on your host:

```bash
docker run --rm --user "$(id -u):$(id -g)" -v "$PWD":/srv \
  ghcr.io/jinalshah/devops/images/all-devops:latest terraform fmt -recursive /srv
```

## Credentials and Authentication

```bash
# AWS
docker run --rm -v ~/.aws:/root/.aws ghcr.io/jinalshah/devops/images/aws-devops:latest aws sts get-caller-identity

# GCP
docker run --rm -v ~/.config/gcloud:/root/.config/gcloud ghcr.io/jinalshah/devops/images/gcp-devops:latest gcloud auth list

# SSH
docker run --rm -v ~/.ssh:/root/.ssh ghcr.io/jinalshah/devops/images/all-devops:latest ssh -V
```

## Pinning Tags for CI/CD

Use immutable version tags for predictable pipelines:

```bash
docker pull ghcr.io/jinalshah/devops/images/all-devops:1.0.<sha7>
```

Prefer `latest` for local interactive use, and version tags for CI.

## Using in GitHub Actions

```yaml
jobs:
  validate:
    runs-on: ubuntu-latest
    container:
      image: ghcr.io/jinalshah/devops/images/all-devops:latest
    steps:
      - uses: actions/checkout@v4
      - run: terraform version
      - run: ansible --version
```
