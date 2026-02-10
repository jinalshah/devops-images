# All DevOps

## DevOps Image

### All DevOps Image

#### All DevOps: GitLab Container Registry

Pull the Image from the GitLab Container Registry:

```bash
docker pull ghcr.io/jinalshah/devops/images/all-devops:latest
```

Run the Image from the GitLab Container Registry:

```bash
docker run -it ghcr.io/jinalshah/devops/images/all-devops:latest zsh
```

Run with volume mounts for seamless host/container file access:

```bash
docker run -it \
  -v $PWD:/workspace \
  -v ~/.ssh:/home/devops/.ssh \
  -v ~/.aws:/home/devops/.aws \
  ghcr.io/jinalshah/devops/images/all-devops:latest
```

#### All DevOps: GitHub Container Registry

Pull the Image from the GitHub Container Registry:

```bash
docker pull ghcr.io/jinalshah/devops/images/all-devops:latest
```

Run the Image from the GitHub Container Registry:

```bash
docker run -it ghcr.io/jinalshah/devops/images/all-devops:latest zsh
```

Run with volume mounts for seamless host/container file access:

```bash
docker run -it \
  -v $PWD:/workspace \
  -v ~/.ssh:/home/devops/.ssh \
  -v ~/.aws:/home/devops/.aws \
  ghcr.io/jinalshah/devops/images/all-devops:latest
```
