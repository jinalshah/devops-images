# all-devops

This repository contains all the common DevOps tooling required for a typical project on AWS and GCP.

[![pipeline status](https://gitlab.com/jinal-shah/devops/images/badges/master/pipeline.svg)](https://gitlab.com/jinal-shah/devops/images/-/commits/master)

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
-t registry.gitlab.com/jinal-shah/devops/all-devops/all-devops.image-base.centos:latest \
-t registry.gitlab.com/jinal-shah/devops/all-devops/all-devops.image-base.centos:${IMAGE_VERSION} .
```

### Push the Image to GitLab

```bash
docker push registry.gitlab.com/jinal-shah/devops/all-devops/all-devops.image-base.centos:latest && \
docker push registry.gitlab.com/jinal-shah/devops/all-devops/all-devops.image-base.centos:${IMAGE_VERSION}
```

### Building the Image with GitLab Tags and Pushing the Image to GitLab

```bash
export IMAGE_VERSION=1.6
docker build \
-t registry.gitlab.com/jinal-shah/devops/all-devops/all-devops.image-base.centos:latest \
-t registry.gitlab.com/jinal-shah/devops/all-devops/all-devops.image-base.centos:${IMAGE_VERSION} . && \
docker push registry.gitlab.com/jinal-shah/devops/all-devops/all-devops.image-base.centos:latest && \
docker push registry.gitlab.com/jinal-shah/devops/all-devops/all-devops.image-base.centos:${IMAGE_VERSION}
```

### Running the the Remote Image

```bash
docker run -it registry.gitlab.com/jinal-shah/devops/all-devops/all-devops.image-base.centos
```