# Build: All DevOps

## Local Build

```bash
docker build --target all-devops -t all-devops:local .
```

## Run

```bash
docker run -it --rm all-devops:local
```

## Quick Verification

```bash
docker run --rm all-devops:local terraform version
docker run --rm all-devops:local aws --version
docker run --rm all-devops:local gcloud --version
docker run --rm all-devops:local trivy --version
```

## Custom Build Example

```bash
docker build \
  --target all-devops \
  --build-arg PYTHON_VERSION=3.12.4 \
  --build-arg K9S_VERSION=0.32.7 \
  -t all-devops:custom .
```
