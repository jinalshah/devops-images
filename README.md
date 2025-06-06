# DevOps Images

[![Build and Push](https://github.com/jinalshah/devops-images/actions/workflows/image-builder.yml/badge.svg)](https://github.com/jinalshah/devops-images/actions/workflows/image-builder.yml)

This repository contains all the common DevOps tooling required for a typical project on AWS or GCP.

- [DevOps Images](#devops-images)
  - [How do I use the DevOps Images?](#how-do-i-use-the-devops-images)
  - [Reading the Documentation](#reading-the-documentation)
    - [On the Web](#on-the-web)
    - [Locally on your machine (To Preview as you Write)](#locally-on-your-machine-to-preview-as-you-write)
      - [Reading the Documentation via your Host Machine](#reading-the-documentation-via-your-host-machine)
      - [Reading the Documentation via Docker](#reading-the-documentation-via-docker)
        - [Option 1](#option-1)
        - [Option 2](#option-2)

## How do I use the DevOps Images?

The full documentation on the DevOps Images can be accessed here: [https://jinalshah.github.io/devops-images/](https://jinalshah.github.io/devops-images/)

## Reading the Documentation

There are several ways to access the documentation. The options have been listed below.

### On the Web

The documentation can be directly viewed on your browser:

[https://jinalshah.github.io/devops-images/](https://jinalshah.github.io/devops-images/)

### Locally on your machine (To Preview as you Write)

#### Reading the Documentation via your Host Machine

Ensure you are the root of this repository.

Ensure `mkdocs` is installed on your machine. If not, you can install it using: `python3 -m pip install --upgrade mkdocs-material`

```bash
mkdocs serve
```

Then access the documentation on your browser by visiting:

[http://localhost:8000](http://localhost:8000)

#### Reading the Documentation via Docker

##### Option 1

Ensure you are at the root of this repository.

Start a container:

```bash
docker run -it --name devops-images-docs -v $PWD:/srv -p 8000:8000 ghcr.io/jinalshah/devops/images/all-devops
```

Navigate to the /srv directory on the container (where the root of this repository is mapped):

```bash
cd /srv
```

Serve the documents so that they are accessible from your host machine:

```bash
mkdocs serve -a 0.0.0.0:8000
```

Then access the documentation on your browser by visiting:

[http://localhost:8000](http://localhost:8000)

##### Option 2

Ensure you are at the root of this repository.

```bash
docker run --rm -it -p 8000:8000 -v ${PWD}:/docs squidfunk/mkdocs-material
```

Then access the documentation on your browser by visiting:

[http://localhost:8000](http://localhost:8000)
