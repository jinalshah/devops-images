---
title: Docker Compose
---

# Docker Compose examples

Compose files for local development: a DevOps workspace next to the databases, object storage or docs server you're working with. Everything here uses **Docker Compose v2** (`docker compose`, no hyphen), so the files have no `version:` key.

```mermaid
flowchart LR
  D["devops<br/>all-devops workspace"] --> PG[("postgres")]
  D --> MG[("mongodb")]
  D --> S3[("minio<br/>S3 API")]
  D --> Docs["docs<br/>zensical serve"]

  classDef all fill:#7c3aed,stroke:#5b21b6,color:#fff
  classDef base fill:#0d9488,stroke:#0f766e,color:#fff
  classDef neutral fill:#334155,stroke:#1e293b,color:#fff
  class D all
  class PG,MG,S3 base
  class Docs neutral
```

Services on the same Compose network reach each other by service name, so `psql -h postgres` works from inside the `devops` container.

!!! info "What the images can't do"
    The images include no Docker CLI or daemon, so Docker-in-Docker and `docker build` inside the workspace won't work. They also have no `redis-cli`. Run those from your host.

## Minimal workspace

```yaml title="compose.yaml"
services:
  devops:
    image: ghcr.io/jinalshah/devops/images/all-devops:latest
    working_dir: /srv
    volumes:
      - .:/srv
      - ~/.ssh:/root/.ssh:ro
      - ~/.aws:/root/.aws
      - ~/.config/gcloud:/root/.config/gcloud
      - ~/.kube:/root/.kube
    stdin_open: true
    tty: true
```

```bash
docker compose run --rm devops                   # interactive zsh
docker compose run --rm devops terraform plan    # one-off command
```

## Workspace with databases

The image ships `psql` 17, `mongosh` and the `mysql` 8.4 client, so you can talk to local databases straight away.

```yaml title="compose.yaml"
services:
  postgres:
    image: postgres:17
    environment:
      POSTGRES_USER: devops
      POSTGRES_PASSWORD: devops
      POSTGRES_DB: infrastructure
    volumes:
      - postgres-data:/var/lib/postgresql/data
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U devops"]
      interval: 5s
      retries: 5

  mongodb:
    image: mongo:8.0
    environment:
      MONGO_INITDB_ROOT_USERNAME: devops
      MONGO_INITDB_ROOT_PASSWORD: devops
    volumes:
      - mongo-data:/data/db

  devops:
    image: ghcr.io/jinalshah/devops/images/all-devops:latest
    depends_on:
      postgres:
        condition: service_healthy
      mongodb:
        condition: service_started
    working_dir: /srv
    volumes:
      - .:/srv
      - ~/.ssh:/root/.ssh:ro
    environment:
      POSTGRES_URL: postgresql://devops:devops@postgres:5432/infrastructure
      MONGO_URL: mongodb://devops:devops@mongodb:27017
    stdin_open: true
    tty: true

volumes:
  postgres-data:
  mongo-data:
```

```bash
docker compose up -d
docker compose exec devops zsh

# Inside the container
psql "$POSTGRES_URL" -c 'SELECT version();'
mongosh "$MONGO_URL" --eval 'db.runCommand({ ping: 1 })'
```

## Local S3 backend for Terraform

[MinIO](https://github.com/minio/minio) provides an S3-compatible API, which is handy for trying out remote state without an AWS account.

!!! note "MinIO images"
    MinIO no longer publishes community images: `minio/minio` and `minio/mc` are gone from Docker Hub. This example uses Chainguard's free builds (`cgr.dev/chainguard/minio` and `cgr.dev/chainguard/minio-client`). The client image has no shell, so it reads the server address from `MC_HOST_local` and runs a single `mc` command.

```yaml title="compose.yaml"
services:
  minio:
    image: cgr.dev/chainguard/minio:latest
    command: server /data --console-address ":9001"
    environment:
      MINIO_ROOT_USER: minioadmin
      MINIO_ROOT_PASSWORD: minioadmin
    ports:
      - "9001:9001"   # web console
    volumes:
      - minio-data:/data
    healthcheck:
      test: ["CMD", "bash", "-c", "exec 3<>/dev/tcp/127.0.0.1/9000"]
      interval: 5s
      retries: 10

  create-bucket:
    image: cgr.dev/chainguard/minio-client:latest
    depends_on:
      minio:
        condition: service_healthy
    environment:
      MC_HOST_local: http://minioadmin:minioadmin@minio:9000
    command: mb --ignore-existing local/terraform-state

  devops:
    image: ghcr.io/jinalshah/devops/images/all-devops:latest
    depends_on:
      create-bucket:
        condition: service_completed_successfully
    working_dir: /srv
    volumes:
      - .:/srv
    environment:
      AWS_ACCESS_KEY_ID: minioadmin
      AWS_SECRET_ACCESS_KEY: minioadmin
      AWS_DEFAULT_REGION: us-east-1
      AWS_ENDPOINT_URL_S3: http://minio:9000
    stdin_open: true
    tty: true

volumes:
  minio-data:
```

Point the backend at MinIO using the current S3 backend arguments (`endpoints`, `use_path_style` and `use_lockfile`; the old `endpoint`, `force_path_style` and `dynamodb_table` are deprecated):

```hcl title="backend.tf"
terraform {
  backend "s3" {
    bucket                      = "terraform-state"
    key                         = "dev/terraform.tfstate"
    region                      = "us-east-1"
    endpoints                   = { s3 = "http://minio:9000" }
    use_path_style              = true
    use_lockfile                = true
    skip_credentials_validation = true
    skip_metadata_api_check     = true
    skip_region_validation      = true
    skip_requesting_account_id  = true
  }
}
```

```bash
docker compose up -d
docker compose exec devops terraform init
docker compose exec devops aws s3 ls s3://terraform-state   # AWS CLI honours AWS_ENDPOINT_URL_S3
```

## Local validation profiles

Compose profiles give you one-word commands for checks you'd otherwise run in CI.

```yaml title="compose.yaml"
x-devops: &devops
  image: ghcr.io/jinalshah/devops/images/all-devops:latest
  working_dir: /srv
  volumes:
    - .:/srv
    - ~/.aws:/root/.aws

services:
  validate:
    <<: *devops
    profiles: [check]
    command: >
      bash -c "terraform fmt -check -recursive &&
               terraform init -backend=false &&
               terraform validate &&
               tflint --init && tflint &&
               trivy config ."

  plan:
    <<: *devops
    profiles: [plan]
    command: bash -c "terraform init && terraform plan"
```

```bash
docker compose run --rm validate
docker compose run --rm plan
```

## Preview docs with Zensical

The <span class="di-pill di-pill--all">all-devops</span> image includes [Zensical](https://zensical.org/), which is what builds this site, so you can preview a Zensical docs project without installing anything:

```yaml title="compose.yaml"
services:
  docs:
    image: ghcr.io/jinalshah/devops/images/all-devops:latest
    working_dir: /srv
    volumes:
      - .:/srv
    ports:
      - "8000:8000"
    command: zensical serve -a 0.0.0.0:8000
```

```bash
docker compose up docs    # then open http://localhost:8000
```

## Keep secrets in `.env`

Compose reads a `.env` file next to `compose.yaml` automatically. Add it to `.gitignore`.

```bash title=".env"
DEVOPS_IMAGE=ghcr.io/jinalshah/devops/images/all-devops:1.0.abc1234
POSTGRES_PASSWORD=changeme
```

```yaml title="compose.yaml"
services:
  devops:
    image: ${DEVOPS_IMAGE}
    environment:
      PGPASSWORD: ${POSTGRES_PASSWORD}
```

## Cheat sheet

| Command | What it does |
|---------|--------------|
| `docker compose up -d` | Start all services in the background |
| `docker compose exec devops zsh` | Open a shell in the running workspace |
| `docker compose run --rm devops <cmd>` | Run a one-off command in a fresh container |
| `docker compose logs -f <service>` | Follow a service's logs |
| `docker compose down` | Stop and remove containers |
| `docker compose down -v` | Also remove named volumes (deletes data) |
| `docker compose pull` | Fetch newer images |

## Next steps

- [Quick reference](quick-reference.md)
- [Authentication](authentication.md)
- [Workflows & patterns](../workflows/index.md)
