# Building Images

This section explains local builds for one image, all images, and advanced build scenarios.

## Prerequisites

- Docker with BuildKit support
- Enough disk space for toolchain-heavy builds
- Internet access during build to fetch package and binary dependencies

## Build a Specific Image

```bash
# all-devops
docker build --target all-devops -t all-devops:local .

# aws-devops
docker build --target aws-devops -t aws-devops:local .

# gcp-devops
docker build --target gcp-devops -t gcp-devops:local .
```

## Build All Images Locally

```bash
for target in all-devops aws-devops gcp-devops; do
  docker build --target "$target" -t "$target:local" .
done
```

## Validate Local Images

```bash
docker run --rm all-devops:local terraform version
docker run --rm aws-devops:local aws --version
docker run --rm gcp-devops:local gcloud --version
```

Optional helper tests in this repository:

```bash
./test_network_tools.sh all-devops:local
./test_dns_tools.sh all-devops:local
./test_ncat_tool.sh all-devops:local
```

## Build Args

You can override selected versions at build time:

```bash
docker build \
  --target all-devops \
  --build-arg GCLOUD_VERSION=501.0.0 \
  --build-arg TERRAGRUNT_VERSION=0.68.14 \
  -t all-devops:custom .
```

Common build args include:

- `GCLOUD_VERSION`
- `PACKER_VERSION`
- `TERRAGRUNT_VERSION`
- `TFLINT_VERSION`
- `GHORG_VERSION`
- `K9S_VERSION`
- `PYTHON_VERSION`
- `PYTHON_VERSION_TO_USE`
- `MONGODB_VERSION`
- `MONGODB_REPO_PATH`

## Advanced Build Topics

- Multi-platform builds and push flow: [Multi-platform Images](multi-platform-images.md)
- Cloud-specific local build pages:
  - [All DevOps](all-devops.md)
  - [AWS DevOps](aws-devops.md)
  - [GCP DevOps](gcp-devops.md)
