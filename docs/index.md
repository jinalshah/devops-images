# Getting Started

This repository contains all the common DevOps tooling required for a typical project on AWS or GCP.

There are three types of DevOps Images available for use:

- All-DevOps: Contains tools for both AWS and GCP environments.
- AWS-DevOps: Contains tools for AWS environments.
- GCP-DevOps: Contains tools for GCP environments.

## Quick Start

### All DevOps Image

#### All DevOps: GitHub Container Registry

Pull the Image:

```bash
docker pull ghcr.io/jinalshah/devops/images/all-devops:latest
```

Run the Image:

```bash
docker run -it ghcr.io/jinalshah/devops/images/all-devops:latest zsh
```

### AWS DevOps Image

#### AWS DevOps: GitHub Container Registry

Pull the Image:

```bash
docker pull ghcr.io/jinalshah/devops/images/aws-devops:latest
```

Run the Image:

```bash
docker run -it ghcr.io/jinalshah/devops/images/aws-devops:latest zsh
```

### GCP DevOps Image

#### GCP DevOps: GitHub Container Registry

Pull the Image:

```bash
docker pull ghcr.io/jinalshah/devops/images/gcp-devops:latest
```

Run the Image:

```bash
docker run -it ghcr.io/jinalshah/devops/images/gcp-devops:latest zsh
```

## Contributing to Documentation

If you notice outdated or missing information, contributions are welcome! Edit the relevant Markdown files in the `docs/` directory and submit a pull request.

## Support & Feature Requests

For issues, feature requests, or to request new tools in the images, please open an issue on the repository.

## Registries

Images are available on both GitHub and GitLab Container Registries. See the [Using the DevOps Images](use-images/index.md) section for full details.

## More Information

- [Building Images](build-images/index.md)
- [Troubleshooting](troubleshooting/index.md)
- [Using Images](use-images/index.md)
