# Troubleshooting

This guide covers common issues and their solutions when working with DevOps Images.

---

## Image Pull Issues

### `pull access denied` or `manifest unknown`

**Symptoms:**

```text
Error response from daemon: pull access denied for ghcr.io/jinalshah/devops/images/all-devops
```

**Solutions:**

1. **Verify the image path is correct:**

   ```bash
   # Correct paths
   ghcr.io/jinalshah/devops/images/all-devops:latest
   registry.gitlab.com/jinal-shah/devops/images/all-devops:latest
   js01/all-devops:latest
   ```

2. **Check if you need authentication:**

   ```bash
   # For GHCR
   docker login ghcr.io

   # For GitLab
   docker login registry.gitlab.com

   # For Docker Hub
   docker login
   ```

3. **Verify the tag exists:**

   ```bash
   # List available tags on GitHub
   gh api repos/jinalshah/devops-images/pkgs/container/devops%2Fimages%2Fall-devops/versions
   ```

4. **Try a different registry:**

   ```bash
   # If GHCR fails, try Docker Hub
   docker pull js01/all-devops:latest
   ```

### Registry rate limits (Docker Hub)

**Symptoms:**

```text
Error response from daemon: toomanyrequests: You have reached your pull rate limit
```

**Solutions:**

1. **Use GHCR or GitLab registry instead:**

   ```bash
   docker pull ghcr.io/jinalshah/devops/images/all-devops:latest
   ```

2. **Authenticate to increase Docker Hub limits:**

   ```bash
   docker login
   # Then retry pull
   ```

3. **In CI/CD, use authenticated pulls:**

   ```yaml
   # GitHub Actions example
   - name: Login to Docker Hub
     uses: docker/login-action@v3
     with:
       username: ${{ secrets.DOCKERHUB_USERNAME }}
       password: ${{ secrets.DOCKERHUB_TOKEN }}
   ```

### Network timeouts during pull

**Solutions:**

1. **Retry with exponential backoff in CI:**

   ```bash
   for i in {1..3}; do
     docker pull ghcr.io/jinalshah/devops/images/all-devops:latest && break
     echo "Retry $i failed, waiting..."
     sleep $((i * 10))
   done
   ```

2. **Use a closer registry mirror or CDN**

3. **Check your network connection and firewall settings**

---

## Container Runtime Issues

### Files created as root on host

**Symptoms:**
Files created by the container are owned by `root:root` on the host, making them difficult to modify.

**Solution:**

Run container with your host user ID:

```bash
docker run --rm --user "$(id -u):$(id -g)" \
  -v "$PWD":/srv \
  ghcr.io/jinalshah/devops/images/all-devops:latest \
  terraform fmt -recursive /srv
```

**Alternative for persistent containers:**

```bash
# Create a wrapper script
cat > ~/bin/devops <<'EOF'
#!/bin/bash
docker run --rm --user "$(id -u):$(id -g)" \
  -v "$PWD":/workspace \
  -w /workspace \
  ghcr.io/jinalshah/devops/images/all-devops:latest "$@"
EOF
chmod +x ~/bin/devops

# Now use it
devops terraform plan
```

### Permission denied on mounted volumes

**Symptoms:**

```text
bash: /srv/script.sh: Permission denied
```

**Solutions:**

1. **Ensure files have execute permissions:**

   ```bash
   chmod +x script.sh
   ```

2. **Mount as read-only if you only need to read:**

   ```bash
   docker run --rm -v "$PWD":/srv:ro ghcr.io/jinalshah/devops/images/all-devops:latest cat /srv/file.txt
   ```

3. **Check SELinux context (on RHEL/CentOS/Fedora):**

   ```bash
   # Add :z or :Z suffix to volume mount
   docker run --rm -v "$PWD":/srv:z ghcr.io/jinalshah/devops/images/all-devops:latest ls /srv
   ```

### Container exits immediately

**Symptoms:**
Container starts and exits right away when using `docker run -d`.

**Solution:**

The images default to an interactive shell. Use `-it` or provide a long-running command:

```bash
# For interactive use
docker run -it ghcr.io/jinalshah/devops/images/all-devops:latest

# For background daemon (less common)
docker run -d ghcr.io/jinalshah/devops/images/all-devops:latest sleep infinity
```

### Out of disk space

**Symptoms:**

```text
no space left on device
```

**Solutions:**

1. **Clean up Docker resources:**

   ```bash
   # Remove unused images
   docker image prune -a

   # Remove all unused resources
   docker system prune -a --volumes
   ```

2. **Check Docker disk usage:**

   ```bash
   docker system df
   ```

3. **Increase Docker Desktop disk allocation (macOS/Windows)**

---

## Cloud Provider Authentication Issues

### AWS credentials not found

**Symptoms:**

```text
Unable to locate credentials. You can configure credentials by running "aws configure"
```

**Solutions:**

1. **Mount AWS credentials directory:**

   ```bash
   docker run --rm -v ~/.aws:/root/.aws \
     ghcr.io/jinalshah/devops/images/aws-devops:latest \
     aws sts get-caller-identity
   ```

2. **Pass credentials as environment variables:**

   ```bash
   docker run --rm \
     -e AWS_ACCESS_KEY_ID \
     -e AWS_SECRET_ACCESS_KEY \
     -e AWS_SESSION_TOKEN \
     ghcr.io/jinalshah/devops/images/aws-devops:latest \
     aws sts get-caller-identity
   ```

3. **Use IAM roles (in EC2/ECS):**
   Container automatically inherits IAM role when running on AWS infrastructure.

### GCP authentication failed

**Symptoms:**

```text
ERROR: (gcloud.auth.list) Failed to get authentication
```

**Solutions:**

1. **Mount gcloud config directory:**

   ```bash
   docker run --rm -v ~/.config/gcloud:/root/.config/gcloud \
     ghcr.io/jinalshah/devops/images/gcp-devops:latest \
     gcloud auth list
   ```

2. **Use service account key file:**

   ```bash
   docker run --rm \
     -v /path/to/service-account.json:/key.json \
     -e GOOGLE_APPLICATION_CREDENTIALS=/key.json \
     ghcr.io/jinalshah/devops/images/gcp-devops:latest \
     gcloud auth list
   ```

3. **Authenticate inside container:**

   ```bash
   docker run -it ghcr.io/jinalshah/devops/images/gcp-devops:latest
   # Inside container:
   gcloud auth login
   gcloud auth application-default login
   ```

### SSH key not found for Git operations

**Symptoms:**

```text
Permission denied (publickey)
```

**Solutions:**

1. **Mount SSH directory:**

   ```bash
   docker run --rm -v ~/.ssh:/root/.ssh \
     ghcr.io/jinalshah/devops/images/all-devops:latest \
     git clone git@github.com:user/repo.git
   ```

2. **Set correct SSH key permissions:**

   ```bash
   chmod 600 ~/.ssh/id_rsa
   chmod 644 ~/.ssh/id_rsa.pub
   ```

3. **Use HTTPS instead of SSH:**

   ```bash
   git clone https://github.com/user/repo.git
   ```

---

## Build Issues

### Architecture mismatch errors

**Symptoms:**

```text
exec format error
```

**Solutions:**

1. **Use Buildx for cross-platform builds:**

   ```bash
   # Create buildx builder
   docker buildx create --name multiarch --use

   # Build for specific platform
   docker buildx build --platform linux/arm64 \
     --target all-devops \
     -t all-devops:arm64 \
     --load .
   ```

2. **Verify your platform:**

   ```bash
   docker info | grep -i arch
   uname -m
   ```

3. **Pull platform-specific tag:**

   ```bash
   # For ARM64
   docker pull ghcr.io/jinalshah/devops/images/all-devops:1.0.abc1234-arm64

   # For AMD64
   docker pull ghcr.io/jinalshah/devops/images/all-devops:1.0.abc1234-amd64
   ```

### Build fails on downloading tools

**Symptoms:**

```text
ERROR: failed to solve: process "/bin/sh -c wget ..." did not complete successfully
```

**Solutions:**

1. **Check network connectivity:**

   ```bash
   # Test network in Docker
   docker run --rm alpine ping -c 3 google.com
   ```

2. **Retry the build (transient failures):**

   ```bash
   docker build --target all-devops -t all-devops:local .
   ```

3. **Build with no cache to force re-download:**

   ```bash
   docker build --no-cache --target all-devops -t all-devops:local .
   ```

4. **Check if behind corporate proxy:**

   ```bash
   docker build \
     --build-arg HTTP_PROXY=http://proxy:8080 \
     --build-arg HTTPS_PROXY=http://proxy:8080 \
     --target all-devops -t all-devops:local .
   ```

### Custom build-arg version fails

**Symptoms:**
Build fails when overriding tool versions with `--build-arg`.

**Solutions:**

1. **Verify the version exists:**
   Check the official release pages for the tool you're trying to install.

2. **Revert to defaults:**

   ```bash
   docker build --target all-devops -t all-devops:local .
   ```

3. **Test one build arg at a time:**

   ```bash
   # Test with single override
   docker build --build-arg TERRAGRUNT_VERSION=0.68.14 \
     --target all-devops -t all-devops:test .
   ```

### Build runs out of memory

**Symptoms:**

```text
Killed
```

**Solutions:**

1. **Increase Docker memory limit (Docker Desktop)**

2. **Build stages separately:**

   ```bash
   # Build base first
   docker build --target base -t devops-base:local .

   # Then build specific image
   docker build --target all-devops -t all-devops:local .
   ```

3. **Use build cache:**

   ```bash
   # Subsequent builds will be faster
   docker build --target all-devops -t all-devops:local .
   ```

---

## Tool-Specific Issues

### Terraform state locking errors

**Symptoms:**

```text
Error: Error locking state: Error acquiring the state lock
```

**Solutions:**

1. **Ensure proper AWS credentials are mounted:**

   ```bash
   docker run --rm -v ~/.aws:/root/.aws -v $PWD:/srv \
     ghcr.io/jinalshah/devops/images/all-devops:latest \
     terraform force-unlock LOCK_ID
   ```

2. **Check DynamoDB table exists (for S3 backend)**

3. **Verify network access to backend**

### Kubectl context not found

**Symptoms:**

```text
The connection to the server localhost:8080 was refused
```

**Solutions:**

1. **Mount kubeconfig:**

   ```bash
   docker run --rm -v ~/.kube:/root/.kube \
     ghcr.io/jinalshah/devops/images/all-devops:latest \
     kubectl get pods
   ```

2. **Set KUBECONFIG environment variable:**

   ```bash
   docker run --rm \
     -v ~/.kube/custom-config:/kubeconfig \
     -e KUBECONFIG=/kubeconfig \
     ghcr.io/jinalshah/devops/images/all-devops:latest \
     kubectl get pods
   ```

3. **Get credentials from cloud provider:**

   ```bash
   # For AWS EKS
   aws eks update-kubeconfig --name my-cluster

   # For GKE
   gcloud container clusters get-credentials my-cluster --zone us-central1-a
   ```

### AI CLI tools not authenticated

**Symptoms:**

```text
Error: Not authenticated. Please run: claude auth login
```

**Solutions:**

1. **Authenticate on host first:**

   ```bash
   # On your host machine
   claude auth login
   ```

2. **Mount config directories:**

   ```bash
   docker run -it \
     -v ~/.claude:/root/.claude \
     -v ~/.codex:/root/.codex \
     -v ~/.copilot:/root/.copilot \
     -v ~/.gemini:/root/.gemini \
     ghcr.io/jinalshah/devops/images/all-devops:latest
   ```

3. **Authenticate inside container:**

   ```bash
   docker run -it ghcr.io/jinalshah/devops/images/all-devops:latest
   # Inside container:
   claude auth login
   ```

### Ansible inventory or playbook not found

**Symptoms:**

```text
ERROR! the playbook: playbook.yml could not be found
```

**Solutions:**

1. **Mount project directory:**

   ```bash
   docker run --rm -v $PWD:/workspace -w /workspace \
     ghcr.io/jinalshah/devops/images/all-devops:latest \
     ansible-playbook playbook.yml
   ```

2. **Use absolute paths:**

   ```bash
   docker run --rm -v $PWD:/srv \
     ghcr.io/jinalshah/devops/images/all-devops:latest \
     ansible-playbook /srv/playbook.yml
   ```

---

## Documentation Issues

### `mkdocs` command not found

**Solution:**

```bash
python3 -m pip install --upgrade mkdocs-material
mkdocs serve
```

### Port 8000 already in use

**Solution:**

```bash
# Use different port
mkdocs serve -a 0.0.0.0:8080

# Or kill process using port 8000
lsof -ti:8000 | xargs kill -9
```

### Documentation not updating

**Solutions:**

1. **Stop and restart mkdocs:**

   ```bash
   # Stop with Ctrl+C, then restart
   mkdocs serve
   ```

2. **Clear browser cache or use incognito mode**

3. **Force rebuild:**

   ```bash
   mkdocs build --clean
   mkdocs serve
   ```

---

## Platform-Specific Issues

### Apple Silicon (M1/M2/M3) issues

**Issue: Wrong architecture pulled**

**Solution:**

```bash
# Verify you got ARM64 image
docker run --rm ghcr.io/jinalshah/devops/images/all-devops:latest uname -m
# Should output: aarch64

# Force ARM64 if needed
docker pull --platform linux/arm64 ghcr.io/jinalshah/devops/images/all-devops:latest
```

**Issue: Rosetta compatibility mode warnings**

**Solution:**

Ensure Docker Desktop is using Apple's virtualization framework, not Rosetta.

### Windows WSL2 issues

**Issue: Volume mount performance is slow**

**Solutions:**

1. **Keep files in WSL2 filesystem:**

   ```bash
   # Work from within WSL2 home directory
   cd ~
   docker run -v $PWD:/workspace ...
   ```

2. **Avoid mounting from /mnt/c/ if possible**

**Issue: Line ending problems**

**Solution:**

```bash
# Configure Git to use LF line endings
git config --global core.autocrlf input
```

### Linux permission issues with Docker socket

**Symptoms:**

```text
Got permission denied while trying to connect to the Docker daemon socket
```

**Solutions:**

1. **Add user to docker group:**

   ```bash
   sudo usermod -aG docker $USER
   newgrp docker
   ```

2. **Or use sudo (not recommended for regular use):**

   ```bash
   sudo docker run ...
   ```

---

## Getting Additional Help

If you're still experiencing issues:

### Gather Information

Collect the following information:

```bash
# Docker version
docker --version

# Host architecture
uname -m

# Host OS
cat /etc/os-release  # Linux
sw_vers              # macOS

# Exact error message
docker run ... 2>&1 | tee error.log
```

### Open an Issue

Open an issue on GitHub with:

- **Title**: Clear, concise description of the problem
- **Environment**: Docker version, host OS, architecture
- **Steps to reproduce**: Exact commands you ran
- **Expected behaviour**: What should happen
- **Actual behaviour**: What actually happened
- **Error output**: Full error messages and logs
- **Image and tag**: Which image and version you're using

[Open an issue →](https://github.com/jinalshah/devops-images/issues/new)

### Community Resources

- [GitHub Discussions](https://github.com/jinalshah/devops-images/discussions)
- [Tool-specific documentation](../tool-basics/index.md)
- Individual tool official documentation
