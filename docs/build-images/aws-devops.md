# AWS DevOps

## Building and Running the Image

### Building the Image Locally

#### Clone the Repository

```bash
git clone git@gitlab.com:jinal-shah/devops/images.git
```

#### cd into the directory

```bash
cd images
```

#### Build the Image

```bash
docker build --target aws-devops -t aws-devops:latest .
```

### Running the Locally Built Image

```bash
docker run -it aws-devops:latest
```
