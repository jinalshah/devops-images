# Docker Compose Examples

Pre-configured Docker Compose setups for local development environments using DevOps Images with databases, services, and development tools.

---

## Basic Development Environment

### Minimal Setup

**`docker-compose.yml`**:

```yaml
version: '3.8'

services:
  devops:
    image: ghcr.io/jinalshah/devops/images/all-devops:latest
    container_name: devops-workspace
    volumes:
      - .:/workspace
      - ~/.aws:/root/.aws
      - ~/.config/gcloud:/root/.config/gcloud
      - ~/.ssh:/root/.ssh
    working_dir: /workspace
    stdin_open: true
    tty: true
    command: zsh
```

**Usage**:

```bash
# Start interactive shell
docker-compose run --rm devops

# Run specific command
docker-compose run --rm devops terraform plan
```

---

## Development with Databases

### PostgreSQL + DevOps Tools

```yaml
version: '3.8'

services:
  postgres:
    image: postgres:17-alpine
    container_name: dev-postgres
    environment:
      POSTGRES_USER: devops
      POSTGRES_PASSWORD: devops
      POSTGRES_DB: infrastructure
    ports:
      - "5432:5432"
    volumes:
      - postgres-data:/var/lib/postgresql/data
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U devops"]
      interval: 5s
      timeout: 5s
      retries: 5

  devops:
    image: ghcr.io/jinalshah/devops/images/all-devops:latest
    container_name: devops-workspace
    depends_on:
      postgres:
        condition: service_healthy
    volumes:
      - .:/workspace
      - ~/.aws:/root/.aws
      - ~/.ssh:/root/.ssh
    working_dir: /workspace
    environment:
      DATABASE_URL: postgresql://devops:devops@postgres:5432/infrastructure
    stdin_open: true
    tty: true
    command: zsh

volumes:
  postgres-data:
```

**Usage**:

```bash
# Start all services
docker-compose up -d

# Access DevOps shell
docker-compose exec devops zsh

# Inside container, connect to PostgreSQL
psql postgresql://devops:devops@postgres:5432/infrastructure
```

---

## Multi-Database Environment

### PostgreSQL + MongoDB + Redis

```yaml
version: '3.8'

services:
  postgres:
    image: postgres:17-alpine
    environment:
      POSTGRES_USER: devops
      POSTGRES_PASSWORD: devops
    ports:
      - "5432:5432"
    volumes:
      - postgres-data:/var/lib/postgresql/data

  mongodb:
    image: mongo:6.0
    environment:
      MONGO_INITDB_ROOT_USERNAME: devops
      MONGO_INITDB_ROOT_PASSWORD: devops
    ports:
      - "27017:27017"
    volumes:
      - mongo-data:/data/db

  redis:
    image: redis:7-alpine
    ports:
      - "6379:6379"
    volumes:
      - redis-data:/data

  devops:
    image: ghcr.io/jinalshah/devops/images/all-devops:latest
    depends_on:
      - postgres
      - mongodb
      - redis
    volumes:
      - .:/workspace
      - ~/.aws:/root/.aws
      - ~/.ssh:/root/.ssh
    working_dir: /workspace
    environment:
      POSTGRES_URL: postgresql://devops:devops@postgres:5432/devops
      MONGO_URL: mongodb://devops:devops@mongodb:27017
      REDIS_URL: redis://redis:6379
    stdin_open: true
    tty: true
    command: zsh

volumes:
  postgres-data:
  mongo-data:
  redis-data:
```

**Usage**:

```bash
# Start all services
docker-compose up -d

# Access DevOps shell
docker-compose exec devops zsh

# Inside container
psql $POSTGRES_URL -c "SELECT version();"
mongosh $MONGO_URL
redis-cli -h redis ping
```

---

## CI/CD Testing Environment

### Local Pipeline Testing

```yaml
version: '3.8'

services:
  devops:
    image: ghcr.io/jinalshah/devops/images/all-devops:1.0.abc1234  # (1)!
    volumes:
      - .:/workspace
      - ~/.aws:/root/.aws
      - /var/run/docker.sock:/var/run/docker.sock  # (2)!
    working_dir: /workspace
    environment:
      CI: "true"
      ENVIRONMENT: local
    profiles:
      - test

  validate:
    extends: devops
    command: >
      sh -c "
        terraform fmt -check -recursive &&
        terraform init -backend=false &&
        terraform validate &&
        trivy config .
      "
    profiles:
      - test

  deploy:
    extends: devops
    command: >
      sh -c "
        terraform init &&
        terraform plan &&
        terraform apply -auto-approve
      "
    profiles:
      - deploy
```

1. Pin version for reproducibility
2. Access Docker daemon for Docker-in-Docker operations

**Usage**:

```bash
# Run validation
docker-compose --profile test run --rm validate

# Run deployment
docker-compose --profile deploy run --rm deploy
```

---

## Terraform State Backend

### Local S3-Compatible Storage

```yaml
version: '3.8'

services:
  minio:  # (1)!
    image: minio/minio:latest
    command: server /data --console-address ":9001"
    environment:
      MINIO_ROOT_USER: minioadmin
      MINIO_ROOT_PASSWORD: minioadmin
    ports:
      - "9000:9000"
      - "9001:9001"
    volumes:
      - minio-data:/data
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:9000/minio/health/live"]
      interval: 30s
      timeout: 20s
      retries: 3

  create-bucket:  # (2)!
    image: minio/mc:latest
    depends_on:
      minio:
        condition: service_healthy
    entrypoint: >
      sh -c "
        mc alias set myminio http://minio:9000 minioadmin minioadmin &&
        mc mb myminio/terraform-state || true
      "

  devops:
    image: ghcr.io/jinalshah/devops/images/all-devops:latest
    depends_on:
      - create-bucket
    volumes:
      - .:/workspace
    working_dir: /workspace
    environment:
      AWS_ACCESS_KEY_ID: minioadmin
      AWS_SECRET_ACCESS_KEY: minioadmin
      AWS_ENDPOINT_URL_S3: http://minio:9000
    stdin_open: true
    tty: true
    command: zsh

volumes:
  minio-data:
```

1. MinIO provides S3-compatible local storage
2. Automatically creates Terraform state bucket

**Terraform backend config**:

```hcl
terraform {
  backend "s3" {
    bucket                      = "terraform-state"
    key                         = "dev/terraform.tfstate"
    region                      = "us-east-1"
    endpoint                    = "http://minio:9000"
    skip_credentials_validation = true
    skip_metadata_api_check     = true
    skip_region_validation      = true
    force_path_style            = true
  }
}
```

**Usage**:

```bash
# Start environment
docker-compose up -d

# Access DevOps shell
docker-compose exec devops zsh

# Inside container
terraform init
terraform plan
```

---

## Kubernetes Development

### Kind Cluster + DevOps Tools

```yaml
version: '3.8'

services:
  kind:  # (1)!
    image: kindest/node:v1.27.0
    container_name: kind-control-plane
    privileged: true
    ports:
      - "6443:6443"
      - "80:30080"
      - "443:30443"
    volumes:
      - kind-data:/var

  devops:
    image: ghcr.io/jinalshah/devops/images/all-devops:latest
    depends_on:
      - kind
    volumes:
      - .:/workspace
      - ~/.kube:/root/.kube
    working_dir: /workspace
    environment:
      KUBECONFIG: /root/.kube/config
    network_mode: service:kind  # (2)!
    stdin_open: true
    tty: true
    command: zsh

volumes:
  kind-data:
```

1. Kind (Kubernetes in Docker) for local K8s cluster
2. Share network with Kind to access K8s API

**Usage**:

```bash
# Start cluster
docker-compose up -d

# Access DevOps shell
docker-compose exec devops zsh

# Inside container
kubectl get nodes
kubectl get pods -A
helm list -A
```

---

## Development + Documentation

### MkDocs + DevOps Tools

```yaml
version: '3.8'

services:
  docs:
    image: squidfunk/mkdocs-material:latest
    volumes:
      - .:/docs
    ports:
      - "8000:8000"
    command: serve --dev-addr=0.0.0.0:8000

  devops:
    image: ghcr.io/jinalshah/devops/images/all-devops:latest
    volumes:
      - .:/workspace
      - ~/.aws:/root/.aws
    working_dir: /workspace
    stdin_open: true
    tty: true
    command: zsh
```

**Usage**:

```bash
# Start all services
docker-compose up -d

# View docs
open http://localhost:8000

# Access DevOps shell
docker-compose exec devops zsh
```

---

## Production-Like Environment

### Multi-Service Stack

```yaml
version: '3.8'

networks:
  frontend:
  backend:

services:
  postgres:
    image: postgres:17-alpine
    networks:
      - backend
    environment:
      POSTGRES_USER: app
      POSTGRES_PASSWORD: secret
    volumes:
      - postgres-data:/var/lib/postgresql/data

  redis:
    image: redis:7-alpine
    networks:
      - backend
    volumes:
      - redis-data:/data

  nginx:
    image: nginx:alpine
    networks:
      - frontend
      - backend
    ports:
      - "80:80"
    volumes:
      - ./nginx.conf:/etc/nginx/nginx.conf:ro

  devops:
    image: ghcr.io/jinalshah/devops/images/all-devops:latest
    networks:
      - frontend
      - backend
    volumes:
      - .:/workspace
      - ~/.aws:/root/.aws
      - ~/.kube:/root/.kube
    working_dir: /workspace
    environment:
      DATABASE_URL: postgresql://app:secret@postgres:5432/app
      REDIS_URL: redis://redis:6379
    depends_on:
      - postgres
      - redis
    stdin_open: true
    tty: true
    command: zsh

volumes:
  postgres-data:
  redis-data:
```

---

## Best Practices

!!! tip "Performance"

    1. **Use named volumes**: Better performance than bind mounts
    2. **Health checks**: Ensure services are ready before starting dependent containers
    3. **Resource limits**: Prevent containers from consuming all resources
    4. **Network isolation**: Use custom networks to isolate services

!!! tip "Security"

    1. **Don't commit secrets**: Use `.env` files (add to `.gitignore`)
    2. **Use specific versions**: Pin image versions for reproducibility
    3. **Limit exposed ports**: Only expose necessary ports
    4. **Run as non-root**: Use `user:` directive when possible

!!! warning "Common Pitfalls"

    - ❌ **Using `latest` tag**: Can lead to unexpected behavior
    - ❌ **No health checks**: Dependent services may start before ready
    - ❌ **Committing `.env` files**: Exposes secrets
    - ❌ **No resource limits**: Can cause host exhaustion

---

## Environment Variables

### Using `.env` File

**`.env`**:

```bash
# Image versions
DEVOPS_IMAGE=ghcr.io/jinalshah/devops/images/all-devops:1.0.abc1234
POSTGRES_VERSION=17-alpine

# Database credentials
POSTGRES_USER=devops
POSTGRES_PASSWORD=changeme
POSTGRES_DB=infrastructure

# AWS credentials
AWS_ACCESS_KEY_ID=your-key-id
AWS_SECRET_ACCESS_KEY=your-secret-key
AWS_DEFAULT_REGION=us-east-1
```

**`docker-compose.yml`**:

```yaml
version: '3.8'

services:
  postgres:
    image: postgres:${POSTGRES_VERSION}
    environment:
      POSTGRES_USER: ${POSTGRES_USER}
      POSTGRES_PASSWORD: ${POSTGRES_PASSWORD}
      POSTGRES_DB: ${POSTGRES_DB}

  devops:
    image: ${DEVOPS_IMAGE}
    environment:
      AWS_ACCESS_KEY_ID: ${AWS_ACCESS_KEY_ID}
      AWS_SECRET_ACCESS_KEY: ${AWS_SECRET_ACCESS_KEY}
      AWS_DEFAULT_REGION: ${AWS_DEFAULT_REGION}
```

**`.gitignore`**:

```
.env
```

---

## Useful Commands

```bash
# Start all services
docker-compose up -d

# Stop all services
docker-compose down

# View logs
docker-compose logs -f devops

# Access shell
docker-compose exec devops zsh

# Run one-off command
docker-compose run --rm devops terraform plan

# Rebuild images
docker-compose build

# Remove all containers and volumes
docker-compose down -v

# Scale service
docker-compose up -d --scale devops=3
```

---

## Next Steps

- [Quick Reference](quick-reference.md) - Common command patterns
- [Authentication](authentication.md) - Configure cloud credentials
- [Workflows](../workflows/index.md) - Real-world usage examples
- [Troubleshooting](../troubleshooting/index.md) - Common issues
