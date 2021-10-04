# DevOps Images

[![pipeline status](https://gitlab.com/jinal-shah/devops/images/badges/main/pipeline.svg)](https://gitlab.com/jinal-shah/devops/images/-/commits/main)

This repository contains all the common DevOps tooling required for a typical project on AWS or GCP.

## How do I use the DevOps Images?

The full documentation on the DevOps Images can be accessed here: [https://jinal-shah.gitlab.io/devops/images](https://jinal-shah.gitlab.io/devops/images)

## Reading the Documentation

There are several ways to access the documentation. The options have been listed below.

### On the Web

The documentation can be directly viewed on your browser: [https://jinal-shah.gitlab.io/devops/images](https://jinal-shah.gitlab.io/devops/images)

### Locally on your machine

#### Directly from your Host Machine (To Preview as you Write)

Ensure you are the root of this repository.

Ensure `mkdocs` is installed on your machine. If not, you can install it using: `python3 -m pip install --upgrade mkdocs`

```bash
mkdocs serve
```

Then access the documentation on your browser by visiting [http://localhost:8000](http://localhost:8000)

#### Viewing the Documentation via Docker

##### Option 1

Ensure you are at the root of this repository.

Start a container:

```bash
docker run -it --name devops-images-docs -v $PWD:/srv -p 8000:8000 registry.gitlab.com/jinal-shah/devops/images/all-devops
```

Navigate to the /srv directory on the container (where the root of this repository is mapped):

```bash
cd /srv
```

Server the Documents so that they are accessible from your Host Machine:

```bash
mkdocs serve -a 0.0.0.0:8000
```

Then access the documentation on your browser by visiting [http://localhost:8000](http://localhost:8000)

##### Option 2

Ensure you are at the root of this repository.

```bash
docker run --rm -it -p 8000:8000 -v ${PWD}:/docs squidfunk/mkdocs-material
```
