# Reading The Docs

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

Server the Documents so that they are accessible from your Host Machine:

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
