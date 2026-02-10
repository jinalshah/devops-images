# Using the DevOps Images

There are three types of DevOps Images available for use:

- All-DevOps: Contains tools for both AWS and GCP environments.
- AWS-DevOps: Contains tools for AWS environments.
- GCP-DevOps: Contains tools for GCP environments.

All images come equipped with certain universal tools such as:

- Ansible
- Python 3.X
- SSH
- DNS tools (dig, nslookup)
- Network tools (ncat, telnet)
- vim

Additional details on what the images contain can be found within the [Dockerfile](../../Dockerfile).

The images are available on the GitLab Container Registry and the GitHub Container Registry. The links to both registries have been listed below:

| Image Type | GitLab Container Registry                                                                                     | GitHub Container Registry  |
|------------|---------------------------------------------------------------------------------------------------------------|----------------------------|
| All DevOps | [jinal-shah/devops/images/all-devops](https://gitlab.com/jinal-shah/devops/images/container_registry/2301277) | [devops/images/all-devops](https://github.com/users/jinalshah/packages/container/package/devops%2Fimages%2Fall-devops) |
| AWS DevOps | [jinal-shah/devops/images/aws-devops](https://gitlab.com/jinal-shah/devops/images/container_registry/2301280) | [devops/images/aws-devops](https://github.com/users/jinalshah/packages/container/package/devops%2Fimages%2Faws-devops) |
| GCP DevOps | [jinal-shah/devops/images/gcp-devops](https://gitlab.com/jinal-shah/devops/images/container_registry/2301282) | [devops/images/gcp-devops](https://github.com/users/jinalshah/packages/container/package/devops%2Fimages%2Fgcp-devops) |

---

## Updating Images

To pull the latest version of any image:

```bash
docker pull ghcr.io/jinalshah/devops/images/all-devops:latest
```

Replace `all-devops` with `aws-devops` or `gcp-devops` as needed.

## Using with Docker Compose

You can use these images as a base in your own `docker-compose.yml` files. Example:

```yaml
services:
  devops:
    image: ghcr.io/jinalshah/devops/images/all-devops:latest
    command: zsh
    volumes:
      - ./:/workspace
```

## Customising Containers

To add your own tools or configuration, extend the image in your own Dockerfile:

```dockerfile
FROM ghcr.io/jinalshah/devops/images/all-devops:latest
RUN pip install <your-tool>
```

## Registry Notes

- The GitHub Container Registry is recommended for most users.
- The GitLab Container Registry is provided for compatibility and redundancy.

---

## Using Tools Without Accessing the Container Shell

You do not need to open an interactive shell to use the tools provided in these images. You can run any tool directly using `docker run` with the desired command. This is useful for scripting, automation, or CI/CD pipelines.

### Examples

#### Run a Tool Directly

```bash
docker run --rm ghcr.io/jinalshah/devops/images/all-devops:latest ansible --version
docker run --rm ghcr.io/jinalshah/devops/images/aws-devops:latest aws --version
docker run --rm ghcr.io/jinalshah/devops/images/gcp-devops:latest gcloud --version
docker run --rm ghcr.io/jinalshah/devops/images/all-devops:latest dig google.com
docker run --rm ghcr.io/jinalshah/devops/images/all-devops:latest nslookup google.com
docker run --rm ghcr.io/jinalshah/devops/images/all-devops:latest ncat --version
docker run --rm ghcr.io/jinalshah/devops/images/all-devops:latest ncat google.com 80
```

#### Run a Tool on Local Files (Mount a Volume)

If you want to operate on files from your host, mount a directory:

```bash
docker run --rm -v $(pwd):/workspace ghcr.io/jinalshah/devops/images/all-devops:latest ansible-playbook /workspace/playbook.yml
```

#### Use in Scripts or CI/CD

You can use these images in your automation scripts or CI/CD pipelines to run tools in a consistent environment, without needing to install them locally.

---

## Running Tools on Local Files Mounted to /srv

You can also mount your current working directory to `/srv` in the container. This is useful if you want to follow a convention or if some tools/scripts expect files in `/srv`.

### Example

```bash
docker run --rm -v "$(pwd)":/srv ghcr.io/jinalshah/devops/images/all-devops:latest ansible-playbook /srv/playbook.yml
```

Replace `playbook.yml` with your file or script as needed. This approach works for any tool in the image.

---

## Passing Environment Variables

You can pass environment variables from your host to the container using the `-e` flag. This is useful for credentials and configuration:

```bash
docker run --rm -e AWS_ACCESS_KEY_ID -e AWS_SECRET_ACCESS_KEY ghcr.io/jinalshah/devops/images/aws-devops:latest aws s3 ls
```

You can also use `--env-file` to pass multiple variables from a file.

## Mounting Authentication Directories

To use your existing AWS, GCP, or SSH credentials inside the container, mount the relevant directories from your host:

- **AWS CLI:**

  ```bash
  docker run --rm -v ~/.aws:/home/devops/.aws ghcr.io/jinalshah/devops/images/aws-devops:latest aws s3 ls
  ```

- **Google Cloud SDK:**

  ```bash
  docker run --rm -v ~/.config/gcloud:/home/devops/.config/gcloud ghcr.io/jinalshah/devops/images/gcp-devops:latest gcloud auth list
  ```

- **SSH Keys:**

  ```bash
  docker run --rm -v ~/.ssh:/home/devops/.ssh ghcr.io/jinalshah/devops/images/all-devops:latest ssh user@host
  ```

> **Tip:** You can combine multiple `-v` flags to mount several directories at once.

## Using with Podman (rootless)

These images automatically detect and support rootless Podman. When running under rootless Podman:

- The container stays as root (which is actually your unprivileged host user)
- All volume mounts work seamlessly with full read/write access
- You can use any mount path: `/workspace`, `/srv`, or your own custom path

### Examples

**Basic usage** (stays as root, HOME=/home/devops):

```bash
docker run -it --rm -w /srv -v $PWD:/srv ghcr.io/jinalshah/devops/images/aws-devops:latest
```

**With authentication directories**:

```bash
docker run -it --rm \
  -w /srv \
  -v $PWD:/srv \
  -v ~/.ssh:/home/devops/.ssh \
  -v ~/.aws:/home/devops/.aws \
  ghcr.io/jinalshah/devops/images/aws-devops:latest
```

**For a cleaner experience** (lands as devops user instead of root):

```bash
podman run --userns=keep-id:uid=1000,gid=1000 -it --rm \
  -v $PWD:/workspace \
  -v ~/.ssh:/home/devops/.ssh \
  -v ~/.aws:/home/devops/.aws \
  ghcr.io/jinalshah/devops/images/aws-devops:latest
```

> **Note:** The `--userns=keep-id:uid=1000,gid=1000` flag maps your host user to the devops user (UID 1000) inside the container, giving you the standard `devops@container` prompt.

## Troubleshooting Common Docker Issues

- **File Permissions:** The entrypoint script automatically handles UID/GID matching for volume mounts. Files created inside the container will have the correct ownership on your host.

- **Networking:** If you have trouble accessing the internet or internal resources, check your Docker network settings.
- **Volume Mounts on macOS/Windows:** Ensure the path syntax is correct and that Docker Desktop has access to your files.

## Example: Using in GitHub Actions or CI/CD

You can use these images in your CI/CD pipelines. Example for GitHub Actions:

```yaml
jobs:
  deploy:
    runs-on: ubuntu-latest
    container:
      image: ghcr.io/jinalshah/devops/images/all-devops:latest
    steps:
      - uses: actions/checkout@v3
      - run: ansible --version
```

## Support & Feature Requests

For issues, feature requests, or to request new tools in the images, please open an issue on the repository.

---

For more details, see the [Getting Started](../index.md) and [Building Images](../build-images/index.md) sections.
