# Building the DevOps Images

The following guides describe how to build the images locally on your own machine/host. This is especially useful should you need to modify the Dockerfile for your own needs.

For example, if you want to install a specific tool that's currently missing from the existing image, simply clone this repository, modify the Dockerfile as necessary, and build the image locally.

## Step-by-Step Build Instructions

1. Clone this repository:

   ```bash
   git clone https://github.com/jinalshah/devops-images.git
   cd devops-images
   ```

2. Modify the `Dockerfile` as needed.

3. Build the image (replace `<image-name>` as appropriate):

   ```bash
   docker build -t <image-name>:latest .
   ```

4. Run the image:

   ```bash
   docker run -it <image-name>:latest zsh
   ```

## Advanced: Multi-Platform Builds

To build for multiple platforms (e.g., ARM and x86), use Docker Buildx:

```bash
docker buildx build --platform linux/amd64,linux/arm64 -t <image-name>:latest .
```

## Caching and Build Args

- The build process uses caching to speed up builds. You can clear the cache with `docker builder prune` if needed.
- You can pass build arguments using `--build-arg` if the Dockerfile supports them.

## Troubleshooting

See the [Troubleshooting](../troubleshooting/index.md) section for common build issues.
