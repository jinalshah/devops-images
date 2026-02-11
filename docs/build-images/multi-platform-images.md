# Multi-platform Images

The CI workflow publishes multi-arch images for `linux/amd64` and `linux/arm64`. This page shows how to reproduce that locally.

## Create and Use a Buildx Builder

```bash
docker buildx create --name devops-multiarch --use --driver docker-container
docker buildx inspect --bootstrap
```

## Build and Load a Single Platform Locally

Use this when you want a fast local test on your current architecture.

```bash
docker buildx build \
  --platform linux/amd64 \
  --target all-devops \
  -t all-devops:amd64-local \
  --load .
```

## Build and Push Multi-arch to a Registry

```bash
export IMAGE="ghcr.io/jinalshah/devops/images/all-devops"
export VERSION="1.0.$(git rev-parse --short HEAD)"

docker buildx build \
  --platform linux/amd64,linux/arm64 \
  --target all-devops \
  -t "$IMAGE:$VERSION" \
  -t "$IMAGE:latest" \
  --push .
```

Repeat the same pattern for:

- `ghcr.io/jinalshah/devops/images/aws-devops`
- `ghcr.io/jinalshah/devops/images/gcp-devops`
- `registry.gitlab.com/jinal-shah/devops/images/<image>`
- `js01/<image>`

## Verify Manifest and Platforms

```bash
docker buildx imagetools inspect ghcr.io/jinalshah/devops/images/all-devops:latest
```

## Notes

- `--load` supports single-platform output into local Docker engine.
- Multi-platform output generally requires `--push` (registry output).
- Prefer immutable version tags in automation.
