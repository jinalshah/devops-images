# AWS DevOps

## DevOps Image

### AWS DevOps Image

#### AWS DevOps: GitLab Container Registry

Pull the Image from the GitLab Container Registry:

```bash
docker pull ghcr.io/jinalshah/devops/images/aws-devops:latest
```

Run the Image from the GitLab Container Registry:

```bash
docker run -it ghcr.io/jinalshah/devops/images/aws-devops:latest zsh
```

Run with volume mounts for seamless host/container file access:

```bash
docker run -it \
  -v $PWD:/workspace \
  -v ~/.ssh:/home/devops/.ssh \
  -v ~/.aws:/home/devops/.aws \
  ghcr.io/jinalshah/devops/images/aws-devops:latest
```

#### AWS DevOps: GitHub Container Registry

Pull the Image from the GitHub Container Registry:

```bash
docker pull ghcr.io/jinalshah/devops/images/aws-devops:latest
```

Run the Image from the GitHub Container Registry:

```bash
docker run -it ghcr.io/jinalshah/devops/images/aws-devops:latest zsh
```

Run with volume mounts for seamless host/container file access:

```bash
docker run -it \
  -v $PWD:/workspace \
  -v ~/.ssh:/home/devops/.ssh \
  -v ~/.aws:/home/devops/.aws \
  ghcr.io/jinalshah/devops/images/aws-devops:latest
```
