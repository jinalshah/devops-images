# Reading the Documentation

## Published Documentation

The docs site is available at:

- [https://jinalshah.github.io/devops-images/](https://jinalshah.github.io/devops-images/)

## Preview Locally

From the repository root:

```bash
python3 -m pip install --upgrade mkdocs-material
mkdocs serve
```

Then open [http://localhost:8000](http://localhost:8000).

## Preview Using Docker

```bash
docker run --rm -it -p 8000:8000 -v "$PWD":/srv ghcr.io/jinalshah/devops/images/all-devops:latest \
  sh -lc "cd /srv && mkdocs serve -a 0.0.0.0:8000"
```

## Docs Deployment

Docs are deployed by `.github/workflows/docs.yml` when changes are pushed under `docs/**`.

## Common Issues

- Port in use: run `mkdocs serve -a 0.0.0.0:8080` and open port `8080`
- Missing Python package: reinstall with `python3 -m pip install --upgrade mkdocs-material`
- Stale assets: stop and restart `mkdocs serve`
