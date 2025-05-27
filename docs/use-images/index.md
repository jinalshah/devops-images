# Using the DevOps Images

There are three types of DevOps Images available for use:

- All-DevOps: Contains tools for both AWS and GCP environments.
- AWS-DevOps: Contains tools for AWS environments.
- GCP-DevOps: Contains tools for GCP environments.

All images come equipped with certain universal tools such as:

- Ansible
- Python 3.X
- SSH
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

## Customizing Containers

To add your own tools or configuration, extend the image in your own Dockerfile:

```dockerfile
FROM ghcr.io/jinalshah/devops/images/all-devops:latest
RUN pip install <your-tool>
```

## Registry Notes

- The GitHub Container Registry is recommended for most users.
- The GitLab Container Registry is provided for compatibility and redundancy.

---

For more details, see the [Getting Started](../index.md) and [Building Images](../build-images/index.md) sections.
