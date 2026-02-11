# Build: GCP DevOps

## Local Build

```bash
docker build --target gcp-devops -t gcp-devops:local .
```

## Run

```bash
docker run -it --rm gcp-devops:local
```

## Quick Verification

```bash
docker run --rm gcp-devops:local gcloud --version
docker run --rm gcp-devops:local kubectl version --client
docker run --rm gcp-devops:local helm version
```

## Example With Local GCP Credentials

```bash
docker run -it --rm -v ~/.config/gcloud:/root/.config/gcloud gcp-devops:local gcloud auth list
```
