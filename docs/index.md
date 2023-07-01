# Getting Started

This repository contains all the common DevOps tooling required for a typical project on AWS or GCP.

There are three types of DevOps Images available for use:

- All-DevOps: Contains tools for both AWS and GCP environments.
- AWS-DevOps: Contains tools for both AWS environments.
- GCP-DevOps: Contains tools for both GCP environments.

## Quick Start

### All DevOps Image

#### All DevOps: GitLab Container Registry

Pull the Image:

```bash
docker pull ghcr.io/jinalshah/devops/images/all-devops:latest
```

Run the Image:

```bash
docker run -it ghcr.io/jinalshah/devops/images/all-devops:latest zsh
```

### AWS DevOps Image

#### AWS DevOps: GitLab Container Registry

Pull the Image:

```bash
docker pull ghcr.io/jinalshah/devops/images/aws-devops:latest
```

Run the Image:

```bash
docker run -it ghcr.io/jinalshah/devops/images/aws-devops:latest zsh
```

### GCP DevOps Image

#### GCP DevOps: GitLab Container Registry

Pull the Image:

```bash
docker pull ghcr.io/jinalshah/devops/images/gcp-devops:latest
```

Run the Image:

```bash
docker run -it ghcr.io/jinalshah/devops/images/gcp-devops:latest zsh
```

### Pull all three Images simultaneously

#### From the GitLab Container Registry

```bash
docker pull ghcr.io/jinalshah/devops/images/all-devops && \
docker pull ghcr.io/jinalshah/devops/images/aws-devops && \
docker pull ghcr.io/jinalshah/devops/images/gcp-devops
```

#### From the GitHub Container Registry

```bash
docker pull ghcr.io/jinalshah/devops/images/all-devops && \
docker pull ghcr.io/jinalshah/devops/images/aws-devops && \
docker pull ghcr.io/jinalshah/devops/images/gcp-devops
```
