# Building Images

Complete guide to building DevOps Images locally, including benchmarks, optimization strategies, and troubleshooting.

---

## When to Build vs Pull

### Pull from Registry (Recommended)

!!! success "Pull if you need"

    - ✅ **Standard tooling**: Official builds have everything most teams need
    - ✅ **Fast setup**: Pull in seconds vs build in minutes
    - ✅ **Tested builds**: CI/CD tested and scanned for vulnerabilities
    - ✅ **Multi-arch support**: Automatic architecture selection
    - ✅ **Regular updates**: Weekly rebuilds with latest security patches

**Quick pull**:
```bash
docker pull ghcr.io/jinalshah/devops/images/all-devops:latest
```

### Build Locally

!!! example "Build if you need"

    - 🔧 **Custom tools**: Add proprietary or internal tools
    - 🔧 **Specific versions**: Pin tool versions for compliance
    - 🔧 **Size optimization**: Remove unused tools
    - 🔧 **Custom base**: Different Linux distro or base image
    - 🔧 **Air-gapped**: No internet access for pulls

---

## Prerequisites

### System Requirements

| Requirement | Minimum | Recommended | Notes |
|-------------|---------|-------------|-------|
| **Docker** | 20.10+ | 24.0+ | BuildKit required |
| **Disk Space** | 10 GB free | 20 GB free | Build cache + layers |
| **RAM** | 4 GB | 8 GB | Parallel builds benefit |
| **CPU** | 2 cores | 4+ cores | Faster builds |
| **Network** | 10 Mbps | 100 Mbps | Package downloads |

### Enable BuildKit

=== "Docker CLI"

    ```bash
    # Enable for single build
    DOCKER_BUILDKIT=1 docker build .

    # Enable permanently
    echo 'export DOCKER_BUILDKIT=1' >> ~/.bashrc
    source ~/.bashrc
    ```

=== "Docker Desktop"

    1. Open Docker Desktop settings
    2. Go to "Docker Engine"
    3. Add to configuration:
       ```json
       {
         "features": {
           "buildkit": true
         }
       }
       ```
    4. Click "Apply & Restart"

=== "Verify"

    ```bash
    docker version | grep BuildKit
    # Should show: BuildKit: true
    ```

---

## Quick Start

### Build Single Image

=== "all-devops"

    ```bash
    docker build \
      --target all-devops \
      --tag all-devops:local \
      .
    ```

    **Build time**: ~21 minutes (cold), ~3 minutes (warm)

=== "aws-devops"

    ```bash
    docker build \
      --target aws-devops \
      --tag aws-devops:local \
      .
    ```

    **Build time**: ~18 minutes (cold), ~2 minutes (warm)

=== "gcp-devops"

    ```bash
    docker build \
      --target gcp-devops \
      --tag gcp-devops:local \
      .
    ```

    **Build time**: ~19 minutes (cold), ~2.5 minutes (warm)

### Build All Images

```bash
#!/bin/bash
# build-all.sh

for target in all-devops aws-devops gcp-devops; do
  echo "Building $target..."
  docker build \
    --target "$target" \
    --tag "$target:local" \
    .
done
```

**Total build time**: ~60 minutes (cold), ~8 minutes (warm with cache)

---

## Build Time Benchmarks

### Cold Build (No Cache)

| Image | amd64 | arm64 | Notes |
|-------|-------|-------|-------|
| **Base layer** | 15 min | 17 min | Rocky Linux + tools |
| **aws-devops** | 18 min | 20 min | +AWS CLI installation |
| **gcp-devops** | 19 min | 21 min | +gcloud SDK (larger) |
| **all-devops** | 21 min | 23 min | +both cloud CLIs |

### Warm Build (Cached Layers)

| Image | Build Time | Layers Rebuilt | Layers Cached |
|-------|-----------|----------------|---------------|
| **aws-devops** | 2-3 min | AWS layer only | Base layer (15 min saved) |
| **gcp-devops** | 2.5-3.5 min | GCP layer only | Base layer (15 min saved) |
| **all-devops** | 3-4 min | Cloud layers only | Base layer (15 min saved) |

### CI/CD Build Times

| Platform | Cold Build | Warm Build | Cache Strategy |
|----------|-----------|------------|----------------|
| **GitHub Actions** | 20-25 min | 4-6 min | Layer caching enabled |
| **GitLab CI** | 22-27 min | 5-7 min | Registry cache |
| **Jenkins** | 18-23 min | 3-5 min | Persistent volumes |
| **Local (M2 Mac)** | 15-20 min | 2-4 min | BuildKit cache |

---

## Build Cache Strategies

### Strategy 1: Layer Caching (Default)

Docker automatically caches unchanged layers:

```dockerfile
# Layer 1: Base (rarely changes) - CACHED
FROM rockylinux:9

# Layer 2: System packages (monthly) - CACHED
RUN dnf install -y python3 nodejs

# Layer 3: IaC tools (weekly) - REBUILT
RUN install-terraform.sh

# Layer 4: Cloud CLIs (monthly) - REBUILT
RUN install-aws-cli.sh
```

!!! tip "Optimize Layer Order"
    Place frequently changing layers at the end to maximize cache hits.

### Strategy 2: BuildKit Cache Mount

```bash
# Use cache mount for package managers
docker build \
  --target all-devops \
  --cache-from type=local,src=/tmp/buildkit-cache \
  --cache-to type=local,dest=/tmp/buildkit-cache \
  -t all-devops:local .
```

**Benefits**:
- Persistent cache across builds
- Shared cache between projects
- Faster package manager operations

### Strategy 3: Registry Cache

```bash
# Pull previous build as cache
docker pull ghcr.io/jinalshah/devops/images/all-devops:latest

# Build using registry cache
docker build \
  --target all-devops \
  --cache-from ghcr.io/jinalshah/devops/images/all-devops:latest \
  -t all-devops:local .
```

**Benefits**:
- Works in CI/CD without local cache
- Team shares cache via registry
- Consistent across environments

---

## Build Args Reference

### Common Build Args

| Arg | Default | Purpose | Example |
|-----|---------|---------|---------|
| `GCLOUD_VERSION` | Latest | Google Cloud SDK version | `501.0.0` |
| `PACKER_VERSION` | Latest | Packer version | `1.10.0` |
| `TERRAGRUNT_VERSION` | Latest | Terragrunt version | `0.68.14` |
| `TFLINT_VERSION` | Latest | TFLint version | `0.50.0` |
| `K9S_VERSION` | Latest | k9s version | `0.32.0` |
| `PYTHON_VERSION` | `3.12` | Python version | `3.11`, `3.12` |
| `NODE_VERSION` | `20` | Node.js major version | `18`, `20`, `22` |
| `GHORG_VERSION` | Latest | ghorg version | `1.9.0` |
| `MONGODB_VERSION` | `8.0` | MongoDB tools version | `7.0`, `8.0` |

### Using Build Args

```bash
docker build \
  --target all-devops \
  --build-arg GCLOUD_VERSION=500.0.0 \
  --build-arg PACKER_VERSION=1.9.4 \
  --build-arg PYTHON_VERSION=3.11 \
  -t all-devops:custom .
```

### Pin All Versions

```bash
# versions.env
GCLOUD_VERSION=501.0.0
PACKER_VERSION=1.10.0
TERRAGRUNT_VERSION=0.68.14
TFLINT_VERSION=0.50.0
K9S_VERSION=0.32.0

# Build with pinned versions
docker build \
  --target all-devops \
  --build-arg GCLOUD_VERSION=501.0.0 \
  --build-arg PACKER_VERSION=1.10.0 \
  --build-arg TERRAGRUNT_VERSION=0.68.14 \
  --build-arg TFLINT_VERSION=0.50.0 \
  --build-arg K9S_VERSION=0.32.0 \
  -t all-devops:pinned .
```

---

## Validate Builds

### Quick Validation

```bash
# Verify all-devops
docker run --rm all-devops:local terraform version
docker run --rm all-devops:local aws --version
docker run --rm all-devops:local gcloud --version

# Verify aws-devops
docker run --rm aws-devops:local terraform version
docker run --rm aws-devops:local aws --version

# Verify gcp-devops
docker run --rm gcp-devops:local terraform version
docker run --rm gcp-devops:local gcloud --version
```

### Comprehensive Validation

```bash
#!/bin/bash
# validate-build.sh

IMAGE=$1

echo "Validating $IMAGE..."

# Check base tools
docker run --rm $IMAGE terraform version || exit 1
docker run --rm $IMAGE kubectl version --client || exit 1
docker run --rm $IMAGE helm version || exit 1
docker run --rm $IMAGE ansible --version || exit 1
docker run --rm $IMAGE trivy --version || exit 1
docker run --rm $IMAGE python3 --version || exit 1
docker run --rm $IMAGE node --version || exit 1

# Check cloud tools (if present)
docker run --rm $IMAGE aws --version 2>/dev/null && echo "AWS CLI: OK"
docker run --rm $IMAGE gcloud --version 2>/dev/null && echo "gcloud: OK"

echo "✅ Validation complete!"
```

**Usage**:
```bash
./validate-build.sh all-devops:local
```

### Repository Test Scripts

If building from the repository, additional test scripts are available:

```bash
# Test network tools
./test_network_tools.sh all-devops:local

# Test DNS resolution
./test_dns_tools.sh all-devops:local

# Test ncat (network cat)
./test_ncat_tool.sh all-devops:local
```

---

## Optimization Techniques

### Reduce Build Time

=== "Parallel Builds"

    ```bash
    # Build multiple images in parallel
    docker build --target aws-devops -t aws-devops:local . &
    docker build --target gcp-devops -t gcp-devops:local . &
    wait
    ```

=== "BuildKit Parallelism"

    ```bash
    # Enable parallel layer builds
    BUILDKIT_STEP_LOG_MAX_SIZE=10000000 \
    BUILDKIT_STEP_LOG_MAX_SPEED=10000000 \
    docker build --target all-devops -t all-devops:local .
    ```

=== "Fast Package Manager"

    ```dockerfile
    # Use faster mirrors
    RUN sed -i 's|^mirrorlist=|#mirrorlist=|g' /etc/yum.repos.d/Rocky-*.repo && \
        sed -i 's|^#baseurl=http://dl.rockylinux.org|baseurl=https://mirror.example.com|g' /etc/yum.repos.d/Rocky-*.repo
    ```

### Reduce Image Size

See [Optimization Guide](optimization.md) for detailed size reduction techniques.

---

## Troubleshooting

??? question "Build fails with 'No space left on device'"

    **Problem**: Insufficient disk space for build layers

    **Solutions**:

    1. Clean up Docker system:
       ```bash
       docker system prune -a --volumes
       ```

    2. Check available space:
       ```bash
       df -h /var/lib/docker
       ```

    3. Increase Docker Desktop disk size:
       - Settings → Resources → Disk image size → 60 GB

??? question "Build takes extremely long (>1 hour)"

    **Problem**: Network issues or no layer caching

    **Solutions**:

    1. Check network speed:
       ```bash
       curl -o /dev/null https://dl.k8s.io/release/v1.29.0/bin/linux/amd64/kubectl
       ```

    2. Enable BuildKit (faster):
       ```bash
       export DOCKER_BUILDKIT=1
       ```

    3. Use cache from registry:
       ```bash
       docker pull ghcr.io/jinalshah/devops/images/all-devops:latest
       docker build --cache-from ghcr.io/jinalshah/devops/images/all-devops:latest -t all-devops:local .
       ```

??? question "Cannot download packages (404 errors)"

    **Problem**: Package repositories unreachable or versions unavailable

    **Solutions**:

    1. Check internet connectivity:
       ```bash
       ping -c 3 dl.k8s.io
       ```

    2. Use build arg to pin working version:
       ```bash
       docker build --build-arg TERRAGRUNT_VERSION=0.67.0 -t all-devops:local .
       ```

    3. Check Rocky Linux mirrors:
       ```bash
       docker run --rm rockylinux:9 dnf repolist
       ```

??? question "Build fails on M1/M2 Mac"

    **Problem**: Architecture mismatch or emulation issues

    **Solutions**:

    1. Build for native architecture:
       ```bash
       docker build --platform linux/arm64 --target all-devops -t all-devops:local .
       ```

    2. Disable Rosetta emulation in Docker Desktop:
       - Settings → Features in development → Uncheck "Use Rosetta"

    3. Use native arm64 builders:
       ```bash
       docker buildx create --name arm-builder --platform linux/arm64
       docker buildx use arm-builder
       ```

??? question "Python or Node.js version errors"

    **Problem**: Incompatible Python/Node.js version

    **Solutions**:

    1. Specify version with build arg:
       ```bash
       docker build --build-arg PYTHON_VERSION=3.11 -t all-devops:local .
       ```

    2. Check available versions in Dockerfile:
       ```bash
       grep "PYTHON_VERSION" Dockerfile
       ```

??? question "gcloud SDK installation fails"

    **Problem**: Large download, network timeout

    **Solutions**:

    1. Increase build timeout (CI/CD):
       ```yaml
       # GitHub Actions
       timeout-minutes: 60
       ```

    2. Use cached layer:
       ```bash
       docker build --cache-from ghcr.io/jinalshah/devops/images/gcp-devops:latest .
       ```

    3. Download manually and add to build context:
       ```bash
       curl -O https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-sdk-501.0.0-linux-x86_64.tar.gz
       ```

---

## Platform-Specific Builds

### macOS (Apple Silicon)

```bash
# Build for native arm64
docker build \
  --platform linux/arm64 \
  --target all-devops \
  -t all-devops:local .
```

**Notes**:
- Faster than emulated amd64
- All tools have native arm64 support
- No compatibility issues

### Windows (WSL2)

```bash
# From WSL2 terminal
export DOCKER_BUILDKIT=1
docker build --target all-devops -t all-devops:local .
```

**Notes**:
- Use WSL2 for best performance
- Avoid Docker Desktop with Hyper-V (slower)
- Ensure WSL2 has enough memory (Settings → WSL)

### Linux

```bash
# Standard build
docker build --target all-devops -t all-devops:local .
```

**Notes**:
- Best performance (native)
- No emulation overhead
- Fastest build times

---

## Advanced Build Topics

### Multi-Platform Builds

Build for both amd64 and arm64:

```bash
docker buildx build \
  --platform linux/amd64,linux/arm64 \
  --target all-devops \
  -t all-devops:multiarch \
  --load .
```

See [Multi-Platform Images](multi-platform-images.md) for complete guide.

### Custom Builds

Extend images with custom tools:

```bash
# Create custom Dockerfile
FROM ghcr.io/jinalshah/devops/images/all-devops:latest

# Add custom tools
RUN pip3 install custom-package
RUN curl -o /usr/local/bin/custom-tool https://example.com/tool

# Build
docker build -f Dockerfile.custom -t all-devops:custom .
```

See [Customization Guide](customization.md) for detailed examples.

### Automated Builds

Set up CI/CD to build automatically:

- [GitHub Actions](.github/workflows/build.yml) - Example in repository
- [GitLab CI](../workflows/ci-cd-gitlab.md) - Build pipeline
- [Jenkins](../workflows/ci-cd-jenkins.md) - Declarative pipeline

---

## Cloud-Specific Build Guides

Detailed build instructions for each variant:

- [Building all-devops](all-devops.md) - Multi-cloud image
- [Building aws-devops](aws-devops.md) - AWS-optimized image
- [Building gcp-devops](gcp-devops.md) - GCP-optimized image

---

## Best Practices

!!! tip "Build Recommendations"

    1. **Use cache**: Always enable `--cache-from` in CI/CD
    2. **Pin versions**: Use build args to lock versions for reproducibility
    3. **Test locally first**: Validate builds before CI/CD
    4. **Monitor build times**: Track and optimize slow stages
    5. **Clean regularly**: Run `docker system prune` weekly

!!! warning "Common Mistakes"

    - ❌ Building without BuildKit (slower)
    - ❌ No layer caching (rebuilds everything)
    - ❌ Not pinning versions (non-reproducible)
    - ❌ Building on low-spec machines (slow)
    - ❌ Not validating after build (broken images)

---

## Next Steps

- [Optimization Guide](optimization.md) - Reduce size and build time
- [Customization Guide](customization.md) - Extend with custom tools
- [Multi-Platform Guide](multi-platform-images.md) - Build for amd64 and arm64
- [Architecture Overview](../architecture/index.md) - Understand image layers
