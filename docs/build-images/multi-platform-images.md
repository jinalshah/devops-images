# Multi-platform Images

The following guides describe how to Build the Images for Multiple Platforms. This is especially useful should you need to use the Image ond AMD64 and/or ARM64 architectures.

> The examples here use a full registry details in the path as an example because the `build` tool currently has a limitation where it can't build multi-platform Images locally. The registry paths can be modified to suit your needs. They show how to build images for both GitLab and GitHub Container Registries.

## Multi-platform Builds

### Export the Relevant Variables

```bash
export PLATFORMS="linux/arm64,linux/amd64"
export ALL_DEVOPS_IMAGE_NAME="registry.gitlab.com/jinal-shah/devops/images/all-devops"
export GHCR_ALL_DEVOPS_IMAGE_NAME="ghcr.io/jinalshah/devops/images/all-devops"
export AWS_DEVOPS_IMAGE_NAME="registry.gitlab.com/jinal-shah/devops/images/aws-devops"
export GHCR_AWS_DEVOPS_IMAGE_NAME="ghcr.io/jinalshah/devops/images/aws-devops"
export GCP_DEVOPS_IMAGE_NAME="registry.gitlab.com/jinal-shah/devops/images/gcp-devops"
export GHCR_GCP_DEVOPS_IMAGE_NAME="ghcr.io/jinalshah/devops/images/gcp-devops"
export TIMESTAMP=$(date +%Y%m%d-%H%M%S)
export DEVOPS_IMAGE_VERSION="1.0.$TIMESTAMP"

```

### Use the buildx tool to build the images

Activate the use of buildx

```bash
docker buildx create --use
```

#### Build the All DevOps Image

```bash
docker buildx build --platform $PLATFORMS --target all-devops --pull \
-t $ALL_DEVOPS_IMAGE_NAME\:latest \
-t $ALL_DEVOPS_IMAGE_NAME\:$DEVOPS_IMAGE_VERSION \
-t $ALL_DEVOPS_IMAGE_NAME\:$TIMESTAMP \
-t $GHCR_ALL_DEVOPS_IMAGE_NAME\:latest \
-t $GHCR_ALL_DEVOPS_IMAGE_NAME\:$DEVOPS_IMAGE_VERSION \
-t $GHCR_ALL_DEVOPS_IMAGE_NAME\:$TIMESTAMP \
--push .
```

#### Build the AWS DevOps Image

```bash
docker buildx build --platform $PLATFORMS --target aws-devops --pull \
-t $AWS_DEVOPS_IMAGE_NAME\:latest \
-t $AWS_DEVOPS_IMAGE_NAME\:$DEVOPS_IMAGE_VERSION \
-t $AWS_DEVOPS_IMAGE_NAME\:$TIMESTAMP \
-t $GHCR_AWS_DEVOPS_IMAGE_NAME\:latest \
-t $GHCR_AWS_DEVOPS_IMAGE_NAME\:$DEVOPS_IMAGE_VERSION \
-t $GHCR_AWS_DEVOPS_IMAGE_NAME\:$TIMESTAMP \
--push .
```

#### Build the GCP DevOps Image

```bash
docker buildx build --platform $PLATFORMS --target gcp-devops --pull \
-t $GCP_DEVOPS_IMAGE_NAME\:latest \
-t $GCP_DEVOPS_IMAGE_NAME\:$DEVOPS_IMAGE_VERSION \
-t $GCP_DEVOPS_IMAGE_NAME\:$TIMESTAMP \
-t $GHCR_GCP_DEVOPS_IMAGE_NAME\:latest \
-t $GHCR_GCP_DEVOPS_IMAGE_NAME\:$DEVOPS_IMAGE_VERSION \
-t $GHCR_GCP_DEVOPS_IMAGE_NAME\:$TIMESTAMP \
--push .
```
