# GCP DevOps

## DevOps Image

### GCP DevOps Image

#### GCP DevOps: GitLab Container Registry

Pull the Image from the GitLab Container Registry:

```bash
docker pull ghcr.io/jinalshah/devops/images/gcp-devops:latest
```

Run the Image from the GitLab Container Registry:

```bash
docker run -it ghcr.io/jinalshah/devops/images/gcp-devops:latest zsh
```

Run with volume mounts for seamless host/container file access:

```bash
docker run -it \
  -v $PWD:/workspace \
  -v ~/.ssh:/home/devops/.ssh \
  -v ~/.gcloud:/home/devops/.config/gcloud \
  ghcr.io/jinalshah/devops/images/gcp-devops:latest
```

#### GCP DevOps: GitHub Container Registry

Pull the Image from the GitHub Container Registry:

```bash
docker pull ghcr.io/jinalshah/devops/images/gcp-devops:latest
```

Run the Image from the GitHub Container Registry:

```bash
docker run -it ghcr.io/jinalshah/devops/images/gcp-devops:latest zsh
```

Run with volume mounts for seamless host/container file access:

```bash
docker run -it \
  -v $PWD:/workspace \
  -v ~/.ssh:/home/devops/.ssh \
  -v ~/.gcloud:/home/devops/.config/gcloud \
  ghcr.io/jinalshah/devops/images/gcp-devops:latest
```
