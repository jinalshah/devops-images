# Reading the Documentation

## Published Documentation

The docs site is available at:

- [https://jinalshah.github.io/devops-images/](https://jinalshah.github.io/devops-images/)

## Preview Locally

The docs are built with [Zensical](https://zensical.org/) and configured in `zensical.toml`. From the repository root:

```bash
python3 -m pip install --upgrade zensical
zensical serve
```

Then open [http://localhost:8000](http://localhost:8000).

## Preview Using Docker

```bash
docker run --rm -it -p 8000:8000 -v "$PWD":/srv ghcr.io/jinalshah/devops/images/all-devops:latest \
  sh -lc "cd /srv && zensical serve -a 0.0.0.0:8000"
```

## Docs Deployment

Docs are built and deployed by `.github/workflows/docs.yml` when changes under `docs/**` or to `zensical.toml` are pushed to `main`. Pull requests touching the docs run the build without deploying.

## Common Issues

- Port in use: run `zensical serve -a 0.0.0.0:8080` and open port `8080`
- Missing Python package: reinstall with `python3 -m pip install --upgrade zensical`
- Stale assets: stop and restart `zensical serve`
