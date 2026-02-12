# Customising Images

Comprehensive guide to extending DevOps Images with custom tools, packages, and configurations tailored to your team's specific needs.

---

## Why Customise?

!!! example "Common Customisation Reasons"

    - 🔧 **Proprietary tools**: Add internal or licensed software
    - 🔧 **Specific versions**: Lock tool versions for compliance
    - 🔧 **Additional languages**: Add Ruby, Go, Rust, etc.
    - 🔧 **Custom scripts**: Include team-specific automation
    - 🔧 **Organisation standards**: Enforce coding standards, linters
    - 🔧 **Size optimisation**: Remove unused tools

---

## Customisation Approaches

### Approach 1: Extend Existing Image (Recommended)

Fastest and simplest - build on top of official images:

```dockerfile
# Dockerfile.custom
FROM ghcr.io/jinalshah/devops/images/all-devops:latest

# Add your custom tools here
RUN pip3 install custom-package
```

**Pros**:
- ✅ Minimal build time (~2-5 minutes)
- ✅ Inherits all updates from base image
- ✅ Easy to maintain

**Cons**:
- ❌ Cannot remove base tools
- ❌ Slight size overhead

### Approach 2: Fork and Modify Dockerfile

Clone repository and modify the main Dockerfile:

```bash
git clone https://github.com/jinalshah/devops-images
cd devops-images
# Edit Dockerfile
docker build --target all-devops -t my-devops:latest .
```

**Pros**:
- ✅ Full control over all layers
- ✅ Can remove unwanted tools
- ✅ Maximum optimisation

**Cons**:
- ❌ Longer build time (~20+ minutes)
- ❌ Must manually merge upstream updates
- ❌ More complex maintenance

### Approach 3: Multi-Stage with Base

Use base image as builder, copy what you need:

```dockerfile
FROM ghcr.io/jinalshah/devops/images/all-devops:latest AS base

FROM rockylinux:9
# Copy only specific tools from base
COPY --from=base /usr/local/bin/terraform /usr/local/bin/
COPY --from=base /usr/local/bin/kubectl /usr/local/bin/
# Add your custom setup
```

**Pros**:
- ✅ Minimal final image size
- ✅ Pick and choose tools

**Cons**:
- ❌ Complex dependency management
- ❌ May miss library dependencies
- ❌ Higher maintenance

---

## Quick Customisation Examples

### Add Python Packages

```dockerfile
FROM ghcr.io/jinalshah/devops/images/all-devops:latest

# Add Python packages
RUN pip3 install --no-cache-dir \
    requests==2.31.0 \
    pydantic==2.5.0 \
    black==23.12.1 \
    pytest==7.4.3
```

### Add Node.js Packages

```dockerfile
FROM ghcr.io/jinalshah/devops/images/all-devops:latest

# Add Node.js global packages
RUN npm install -g \
    prettier@3.1.1 \
    eslint@8.56.0 \
    typescript@5.3.3
```

### Add System Tools

```dockerfile
FROM ghcr.io/jinalshah/devops/images/all-devops:latest

# Add system packages
RUN dnf install -y \
    httpd-tools \
    nmap \
    tcpdump \
    && dnf clean all
```

### Add Binary Tools

```dockerfile
FROM ghcr.io/jinalshah/devops/images/all-devops:latest

# Add custom binary
RUN curl -fsSL https://example.com/tool -o /usr/local/bin/tool && \
    chmod +x /usr/local/bin/tool
```

---

## Complete Customisation Examples

### Example 1: Development Team Image

Add linters, formatters, and quality tools:

```dockerfile
FROM ghcr.io/jinalshah/devops/images/all-devops:latest

# Python development tools
RUN pip3 install --no-cache-dir \
    black \
    pylint \
    mypy \
    pytest \
    pytest-cov \
    pre-commit

# Node.js development tools
RUN npm install -g \
    prettier \
    eslint \
    @typescript-eslint/parser \
    @typescript-eslint/eslint-plugin

# Add shellcheck for bash linting
RUN dnf install -y ShellCheck && dnf clean all

# Install hadolint for Dockerfile linting
RUN curl -fsSL https://github.com/hadolint/hadolint/releases/download/v2.12.0/hadolint-Linux-x86_64 \
    -o /usr/local/bin/hadolint && \
    chmod +x /usr/local/bin/hadolint

LABEL maintainer="devops@company.com"
LABEL version="1.0"
```

**Build**:
```bash
docker build -f Dockerfile.dev -t company/devops-dev:latest .
```

### Example 2: Security-Focused Image

Add security scanning and hardening tools:

```dockerfile
FROM ghcr.io/jinalshah/devops/images/all-devops:latest

# Security scanning tools
RUN pip3 install --no-cache-dir \
    safety \
    bandit \
    checkov

# Add Snyk CLI
RUN npm install -g snyk

# Add Syft for SBOM generation
RUN curl -sSfL https://raw.githubusercontent.com/anchore/syft/main/install.sh | sh -s -- -b /usr/local/bin

# Add Grype for vulnerability scanning
RUN curl -sSfL https://raw.githubusercontent.com/anchore/grype/main/install.sh | sh -s -- -b /usr/local/bin

# Configure automated scans
COPY scan-scripts/ /opt/security-scripts/
ENV PATH="/opt/security-scripts:${PATH}"

LABEL purpose="security-scanning"
```

### Example 3: Compliance & Audit Image

Pin all tool versions for regulatory compliance:

```dockerfile
# Build args for version pinning
ARG TERRAFORM_VERSION=1.6.6
ARG PACKER_VERSION=1.10.0
ARG PYTHON_VERSION=3.12

FROM ghcr.io/jinalshah/devops/images/all-devops:latest

# Install specific versions
RUN curl -fsSL "https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip" -o terraform.zip && \
    unzip terraform.zip && \
    mv terraform /usr/local/bin/ && \
    rm terraform.zip

RUN curl -fsSL "https://releases.hashicorp.com/packer/${PACKER_VERSION}/packer_${PACKER_VERSION}_linux_amd64.zip" -o packer.zip && \
    unzip packer.zip && \
    mv packer /usr/local/bin/ && \
    rm packer.zip

# Pin Python packages
COPY requirements.txt /tmp/
RUN pip3 install --no-cache-dir -r /tmp/requirements.txt

# Add compliance metadata
LABEL compliance="sox-compliant"
LABEL audit.terraform="${TERRAFORM_VERSION}"
LABEL audit.packer="${PACKER_VERSION}"
```

**requirements.txt**:
```txt
boto3==1.34.12
ansible==9.1.0
cfn-lint==0.85.0
```

### Example 4: Multi-Language Image

Add support for additional programming languages:

```dockerfile
FROM ghcr.io/jinalshah/devops/images/all-devops:latest

# Install Go
ARG GO_VERSION=1.21.5
RUN curl -fsSL "https://go.dev/dl/go${GO_VERSION}.linux-amd64.tar.gz" | tar -C /usr/local -xz
ENV PATH="/usr/local/go/bin:${PATH}"

# Install Rust
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
ENV PATH="/root/.cargo/bin:${PATH}"

# Install Ruby
RUN dnf install -y ruby ruby-devel && dnf clean all
RUN gem install bundler

# Install Java (OpenJDK)
RUN dnf install -y java-17-openjdk-devel && dnf clean all
ENV JAVA_HOME=/usr/lib/jvm/java-17-openjdk

# Verify installations
RUN go version && \
    rustc --version && \
    ruby --version && \
    java -version
```

### Example 5: Minimal Image (Size-Optimised)

Remove unnecessary tools to minimise size:

```dockerfile
# Start from scratch with only what you need
FROM rockylinux:9 AS builder

# Copy only specific tools from official image
FROM ghcr.io/jinalshah/devops/images/all-devops:latest AS source

FROM rockylinux:9

# Copy only Terraform and kubectl
COPY --from=source /usr/local/bin/terraform /usr/local/bin/
COPY --from=source /usr/local/bin/kubectl /usr/local/bin/
COPY --from=source /usr/local/bin/helm /usr/local/bin/

# Add minimal Python
RUN dnf install -y python3 && dnf clean all

CMD ["/bin/bash"]
```

---

## Adding Custom Scripts

### Single Script

```dockerfile
FROM ghcr.io/jinalshah/devops/images/all-devops:latest

# Add custom deployment script
COPY deploy.sh /usr/local/bin/deploy
RUN chmod +x /usr/local/bin/deploy
```

### Script Directory

```dockerfile
FROM ghcr.io/jinalshah/devops/images/all-devops:latest

# Add script directory
COPY scripts/ /opt/company-scripts/
RUN chmod +x /opt/company-scripts/*.sh

# Add to PATH
ENV PATH="/opt/company-scripts:${PATH}"
```

**Project structure**:
```
.
├── Dockerfile
└── scripts/
    ├── deploy-app.sh
    ├── backup-db.sh
    └── security-scan.sh
```

---

## Configuration Management

### Environment Variables

```dockerfile
FROM ghcr.io/jinalshah/devops/images/all-devops:latest

# Set company-specific defaults
ENV COMPANY_NAME="Acme Corp"
ENV DEFAULT_AWS_REGION="us-west-2"
ENV DEFAULT_GCP_PROJECT="acme-prod"
ENV TERRAFORM_BACKEND="s3://acme-terraform-state"
```

### Configuration Files

```dockerfile
FROM ghcr.io/jinalshah/devops/images/all-devops:latest

# Copy configuration files
COPY configs/.terraformrc /root/.terraformrc
COPY configs/.ansible.cfg /root/.ansible.cfg
COPY configs/.gitconfig /root/.gitconfig

# Copy custom shell config
COPY configs/.zshrc.custom /root/.zshrc.d/company.zsh
```

---

## Build Args for Flexibility

### Define Build Args

```dockerfile
ARG BASE_IMAGE=ghcr.io/jinalshah/devops/images/all-devops:latest
ARG PYTHON_PACKAGES="requests pyyaml"
ARG NODE_PACKAGES="prettier eslint"

FROM ${BASE_IMAGE}

RUN pip3 install --no-cache-dir ${PYTHON_PACKAGES}
RUN npm install -g ${NODE_PACKAGES}
```

### Build with Custom Args

```bash
docker build \
  --build-arg BASE_IMAGE=ghcr.io/jinalshah/devops/images/aws-devops:latest \
  --build-arg PYTHON_PACKAGES="boto3 requests" \
  --build-arg NODE_PACKAGES="serverless webpack" \
  -t my-custom-devops:latest \
  .
```

---

## Best Practices

### Layer Optimisation

!!! tip "Minimise Layers"

    Combine RUN commands to reduce layers:

    **Bad** (3 layers):
    ```dockerfile
    RUN pip3 install requests
    RUN pip3 install pyyaml
    RUN pip3 install boto3
    ```

    **Good** (1 layer):
    ```dockerfile
    RUN pip3 install --no-cache-dir \
        requests \
        pyyaml \
        boto3
    ```

### Cache Busting

```dockerfile
# Add this to force rebuild from this point
ARG CACHE_BUST=1

# Subsequent layers will rebuild
COPY requirements.txt /tmp/
RUN pip3 install -r /tmp/requirements.txt
```

### Version Pinning

!!! warning "Always Pin Versions"

    **Bad** (unpredictable):
    ```dockerfile
    RUN pip3 install requests
    ```

    **Good** (reproducible):
    ```dockerfile
    RUN pip3 install requests==2.31.0
    ```

### Cleanup After Install

```dockerfile
RUN dnf install -y httpd-tools && \
    dnf clean all && \
    rm -rf /var/cache/dnf/*
```

### Use .dockerignore

**`.dockerignore`**:
```
.git
.github
*.md
tests/
docs/
.env
.DS_Store
```

---

## Testing Custom Images

### Validation Script

```bash
#!/bin/bash
# test-custom-image.sh

IMAGE=$1

echo "Testing $IMAGE..."

# Test base tools
docker run --rm $IMAGE terraform version || exit 1
docker run --rm $IMAGE kubectl version --client || exit 1

# Test custom additions
docker run --rm $IMAGE python3 -c "import requests; print(requests.__version__)" || exit 1
docker run --rm $IMAGE node -e "console.log(require('prettier').version)" || exit 1

# Test custom scripts
docker run --rm $IMAGE which deploy || exit 1

echo "✅ All tests passed!"
```

### Run Tests

```bash
docker build -t my-devops:test .
./test-custom-image.sh my-devops:test
```

---

## CI/CD Integration

### GitHub Actions

```yaml
name: Build Custom Image

on:
  push:
    branches: [main]

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Build custom image
        run: |
          docker build -t company/devops-custom:${{ github.sha }} .

      - name: Test image
        run: |
          ./test-custom-image.sh company/devops-custom:${{ github.sha }}

      - name: Push to registry
        run: |
          echo "${{ secrets.GITHUB_TOKEN }}" | docker login ghcr.io -u ${{ github.actor }} --password-stdin
          docker push company/devops-custom:${{ github.sha }}
```

### GitLab CI

```yaml
build-custom:
  stage: build
  image: docker:latest
  services:
    - docker:dind
  script:
    - docker build -t $CI_REGISTRY_IMAGE:$CI_COMMIT_SHA .
    - docker push $CI_REGISTRY_IMAGE:$CI_COMMIT_SHA
```

---

## Security Considerations

### Scan Custom Images

```bash
# Scan with Trivy
docker run --rm \
  -v /var/run/docker.sock:/var/run/docker.sock \
  aquasec/trivy image my-devops:latest
```

### Sign Images

```bash
# Sign with Docker Content Trust
export DOCKER_CONTENT_TRUST=1
docker push my-devops:latest
```

### Use Secrets Properly

!!! danger "Never Bake Secrets"

    **Never do this**:
    ```dockerfile
    ENV API_KEY="secret-key-here"
    ```

    **Instead, pass at runtime**:
    ```bash
    docker run -e API_KEY="$API_KEY" my-devops:latest
    ```

---

## Maintenance Strategy

### Automated Rebuilds

```yaml
# .github/workflows/rebuild.yml
name: Rebuild Custom Image

on:
  schedule:
    - cron: '0 2 * * 1'  # Weekly, Monday 2 AM
  workflow_dispatch:

jobs:
  rebuild:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Pull latest base
        run: docker pull ghcr.io/jinalshah/devops/images/all-devops:latest

      - name: Build custom image
        run: docker build -t my-devops:latest .

      - name: Test
        run: ./test-custom-image.sh my-devops:latest

      - name: Push
        run: docker push my-devops:latest
```

### Version Tracking

**Add labels**:
```dockerfile
LABEL base.image="ghcr.io/jinalshah/devops/images/all-devops:1.0.abc1234"
LABEL custom.version="1.2.0"
LABEL custom.build-date="2025-01-15"
LABEL custom.maintainer="devops@company.com"
```

**Check labels**:
```bash
docker inspect my-devops:latest | jq '.[0].Config.Labels'
```

---

## Troubleshooting

??? question "Custom package installation fails"

    **Problem**: Package not found or version incompatible

    **Solutions**:

    1. Check package exists:
       ```bash
       docker run --rm ghcr.io/jinalshah/devops/images/all-devops:latest \
         pip3 search package-name
       ```

    2. Try different version:
       ```dockerfile
       RUN pip3 install package-name==1.2.3
       ```

    3. Install from source:
       ```dockerfile
       RUN pip3 install git+https://github.com/user/package.git@v1.2.3
       ```

??? question "Image size too large"

    **Problem**: Custom image exceeds expected size

    **Solutions**:

    1. Check layer sizes:
       ```bash
       docker history my-devops:latest
       ```

    2. Use multi-stage builds:
       ```dockerfile
       FROM builder AS build
       # Build steps

       FROM ghcr.io/jinalshah/devops/images/all-devops:latest
       COPY --from=build /app /app
       ```

    3. Clean up in same layer:
       ```dockerfile
       RUN pip3 install package && \
           rm -rf /root/.cache/pip
       ```

??? question "Build fails with permission errors"

    **Problem**: Cannot write files or install packages

    **Solutions**:

    1. Run as root (default in Dockerfile):
       ```dockerfile
       USER root
       RUN dnf install -y package
       ```

    2. Fix ownership after:
       ```dockerfile
       RUN chown -R root:root /opt/custom-dir
       ```

---

## Example Repository Structure

```
custom-devops-image/
├── Dockerfile
├── Dockerfile.dev
├── Dockerfile.prod
├── .dockerignore
├── .github/
│   └── workflows/
│       └── build.yml
├── configs/
│   ├── .terraformrc
│   ├── .ansible.cfg
│   └── .gitconfig
├── scripts/
│   ├── deploy.sh
│   ├── backup.sh
│   └── security-scan.sh
├── tests/
│   └── test-image.sh
├── requirements.txt
├── package.json
└── README.md
```

---

## Next Steps

- [Build Images Guide](index.md) - Building from source
- [Optimisation Guide](optimisation.md) - Reduce image size
- [Multi-Platform Images](multi-platform-images.md) - Build for multiple architectures
- [Architecture Overview](../architecture/index.md) - Understand image layers
