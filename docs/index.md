# Getting Started

## Building and Running the Image Locally

### Building the Image Locally

cd into this directory

```bash
docker build -t all-devops:latest .
```

### Running the Locally Built Image

```bash
docker run -it all-devops:latest
```

## How the Image has been Built for GitLab and can be Pulled/Run directly on your Machine

### Building the Image with GitLab Tags

```bash
export IMAGE_VERSION=1.6
docker build \
-t registry.gitlab.com/jinal-shah/devops/images/all-devops.image-base.centos:latest \
-t registry.gitlab.com/jinal-shah/devops/images/all-devops.image-base.centos:${IMAGE_VERSION} .
```

### Push the Image to GitLab

```bash
docker push registry.gitlab.com/jinal-shah/devops/images/all-devops.image-base.centos:latest && \
docker push registry.gitlab.com/jinal-shah/devops/images/all-devops.image-base.centos:${IMAGE_VERSION}
```

### Building the Image with GitLab Tags and Pushing the Image to GitLab

```bash
export IMAGE_VERSION=1.6
docker build \
-t registry.gitlab.com/jinal-shah/devops/images/all-devops.image-base.centos:latest \
-t registry.gitlab.com/jinal-shah/devops/images/all-devops.image-base.centos:${IMAGE_VERSION} . && \
docker push registry.gitlab.com/jinal-shah/devops/images/all-devops.image-base.centos:latest && \
docker push registry.gitlab.com/jinal-shah/devops/images/all-devops.image-base.centos:${IMAGE_VERSION}
```

### Running the the Remote Image

```bash
docker run -it registry.gitlab.com/jinal-shah/devops/images/all-devops.image-base.centos
```

## Tips and Troubleshooting

### Issue with `source ~/.zshrc` on builds

If you run the command `source ~/.zshrc` within the Dockerfile it fails.

This is due to the build/shell throwing an error when one "source" command calls another "source" (i.e. a nested source) within a file.

#### Workaround examples

##### Temporarily Disable and Re-enable `$ZSH/oh-my-zsh.sh` from `~/.zshrc`

Comment Source Lines in `~/.zshrc`:

```bash
sed -i 's/# source $ZSH\/oh-my-zsh.sh/source $ZSH\/oh-my-zsh.sh/g' ~/.zshrc
```

Unomment Source Lines in `~/.zshrc` on all stage builds:

```bash
  sed -i 's/# source <(kubectl completion zsh)/source <(kubectl completion zsh)/g' ~/.zshrc && \
  sed -i 's/# source <(kubectl completion zsh)/source <(kubectl completion zsh)/g' ~/.bashrc && \
  sed -i 's/# source $ZSH\/oh-my-zsh.sh/source $ZSH\/oh-my-zsh.sh/g' ~/.zshrc
```
