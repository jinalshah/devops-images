# Troubleshooting

## Pull and Authentication Problems

### `pull access denied`

- Verify the image path and tag.
- Confirm you are logged in for the target registry:

```bash
docker login ghcr.io
docker login registry.gitlab.com
docker login
```

### Registry rate limits or transient failures

- Retry with exponential backoff in CI.
- Prefer pinned tags so retries fetch the same artifact.

## Container Runtime Issues

### Files created as root on host

Run with host UID/GID:

```bash
docker run --rm --user "$(id -u):$(id -g)" -v "$PWD":/srv ghcr.io/jinalshah/devops/images/all-devops:latest touch /srv/test.txt
```

### Credential files not found

Mount the right directory:

- AWS: `-v ~/.aws:/root/.aws`
- GCP: `-v ~/.config/gcloud:/root/.config/gcloud`
- SSH: `-v ~/.ssh:/root/.ssh`

## Build Failures

### Architecture mismatch

The Dockerfile uses architecture-specific downloads. If you override platforms, use Buildx and verify target platform:

```bash
docker buildx build --platform linux/arm64 --target all-devops -t all-devops:arm64-test --load .
```

### Slow or unstable dependency downloads

- Re-run with a stable network.
- Use build cache where possible.
- For clean rebuild debugging, run with `--no-cache`.

### Tool version conflicts

If a custom `--build-arg` fails, revert to defaults and reintroduce changes one variable at a time.

## Docs Preview Issues

### `mkdocs` command not found

```bash
python3 -m pip install --upgrade mkdocs-material
```

### Port `8000` already in use

```bash
mkdocs serve -a 0.0.0.0:8080
```

## Need Help

Open an issue with:

- exact command
- full error output
- target image and tag
- host OS and architecture (`uname -m`)
