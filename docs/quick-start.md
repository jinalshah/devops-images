# Quick Start Guide

Get up and running with DevOps Images in five minutes. All you need is Docker (or any OCI runtime, such as Podman).

```mermaid
flowchart LR
  A["1. Choose<br/>an image"] --> B["2. Pull it"] --> C["3. Run it"] --> D["4. Try a tool"] --> E["5. Mount your<br/>project and credentials"]
  classDef s1 fill:#4f46e5,stroke:#3730a3,color:#fff
  classDef s2 fill:#7c3aed,stroke:#5b21b6,color:#fff
  classDef s3 fill:#a21caf,stroke:#86198f,color:#fff
  classDef s4 fill:#db2777,stroke:#9d174d,color:#fff
  classDef s5 fill:#ea7a0c,stroke:#c2410c,color:#fff
  class A s1
  class B s2
  class C s3
  class D s4
  class E s5
```

## Step 1: Choose your image

<div class="grid cards di-images" markdown>

-   :lucide-layers: __all-devops__

    ---

    AWS **and** Google Cloud tooling. A good default if you're unsure or work across clouds.

-   :fontawesome-brands-aws: __aws-devops__

    ---

    AWS CLI v2, Session Manager, boto3 and cfn-lint. No Google Cloud SDK.

-   :simple-googlecloud: __gcp-devops__

    ---

    The Google Cloud CLI, GKE auth plugin and docker-credential-gcr. No AWS tooling.

</div>

Still deciding? The [interactive image picker](choosing-an-image.md) asks three questions and gives you the command.

## Step 2: Pull the image

=== "all-devops"

    ```bash
    docker pull ghcr.io/jinalshah/devops/images/all-devops:latest
    ```

=== "aws-devops"

    ```bash
    docker pull ghcr.io/jinalshah/devops/images/aws-devops:latest
    ```

=== "gcp-devops"

    ```bash
    docker pull ghcr.io/jinalshah/devops/images/gcp-devops:latest
    ```

!!! tip "The first pull takes a minute"
    Each image is about **1.5–1.6 GB to download** and roughly **4.6–5 GB on disk** once unpacked. After that, starting a container is instant. Grab a coffee! :lucide-coffee:

## Step 3: Run it interactively

```bash
docker run -it --rm ghcr.io/jinalshah/devops/images/all-devops:latest
```

You land in Zsh with Oh My Zsh's `candy` theme. The prompt looks like this:

```
root@3f2a1b9c8d7e [10:42:07] [/]
-> %
```

Type `exit` (or press ++ctrl+d++) to leave. `--rm` deletes the container afterwards.

## Step 4: Try a tool

```bash
terraform version
kubectl version --client
aws --version         # all-devops and aws-devops
gcloud --version      # all-devops and gcp-devops
claude --version      # plus codex, copilot and agy
```

!!! success "You're in"
    Every tool prints its version, so everything is installed and on your `PATH`.

## Step 5: Set up for real work

Mount your project and the credentials you already have on your machine:

```bash
docker run -it --rm \
  -v "$PWD":/srv -w /srv \
  -v ~/.ssh:/root/.ssh:ro \
  -v ~/.aws:/root/.aws \
  -v ~/.config/gcloud:/root/.config/gcloud \
  ghcr.io/jinalshah/devops/images/all-devops:latest
```

Your project is at `/srv`, and the cloud CLIs use your existing logins.

## Build your command

Pick an image and toggle what you want mounted. The command updates as you click, ready to copy.

<div class="di-widget" data-di-builder markdown>
!!! note "Interactive builder"
    This builder needs JavaScript. Without it, use the command in Step 5 above.
</div>

| Mount | What it gives you |
|-------|-------------------|
| `-v "$PWD":/srv -w /srv` | Your project files, as the working directory |
| `-v ~/.ssh:/root/.ssh:ro` | SSH keys for Git and servers (read-only) |
| `-v ~/.aws:/root/.aws` | AWS CLI profiles and SSO cache |
| `-v ~/.config/gcloud:/root/.config/gcloud` | gcloud logins and configurations |
| `-v ~/.kube:/root/.kube` | kubeconfig for your clusters |
| `-v ~/.claude:/root/.claude` | Claude Code login and settings |
| `-v ~/.codex:/root/.codex` | Codex CLI login and `config.toml` |
| `-v ~/.copilot:/root/.copilot` | Copilot CLI login and settings |
| `-v ~/.gemini:/root/.gemini` | Antigravity CLI (`agy`) login and settings |

---

## What you get

<div class="grid cards" markdown>

-   :simple-terraform: __Infrastructure as code__

    ---

    Terraform (via tfswitch), Terragrunt, TFLint, Packer

-   :simple-kubernetes: __Kubernetes__

    ---

    kubectl, Helm 3, k9s

-   :simple-ansible: __Automation and security__

    ---

    Ansible, ansible-lint, pre-commit, Task, Trivy

-   :lucide-bot: __AI coding agents__

    ---

    Claude Code, Codex CLI, Copilot CLI, Antigravity CLI (`agy`)

-   :simple-python: __Development__

    ---

    Python 3.14, Node.js LTS, Git, GitHub CLI, ghorg, Zensical

-   :lucide-database: __Databases and network__

    ---

    mongosh, psql, mysql · dig, nmap, ncat, curl, jq

</div>

### Cloud tooling per image

| Tool | <span class="di-pill di-pill--all">all-devops</span> | <span class="di-pill di-pill--aws">aws-devops</span> | <span class="di-pill di-pill--gcp">gcp-devops</span> |
|------|:---:|:---:|:---:|
| AWS CLI v2 + Session Manager plugin | :material-check: | :material-check: | — |
| boto3, cfn-lint, s3cmd | :material-check: | :material-check: | — |
| gcloud, gsutil, bq | :material-check: | — | :material-check: |
| GKE auth plugin, docker-credential-gcr | :material-check: | — | :material-check: |

Search the whole list in the [tool explorer](use-images/quick-reference.md#tool-explorer).

---

## Common first tasks

=== ":simple-terraform: Terraform"

    ```bash
    cat > main.tf <<'EOF'
    output "hello" {
      value = "Hello from DevOps Images!"
    }
    EOF

    docker run --rm -v "$PWD":/srv -w /srv \
      ghcr.io/jinalshah/devops/images/all-devops:latest \
      sh -c "terraform init && terraform apply -auto-approve"
    ```

=== ":simple-trivy: Security scan"

    ```bash
    # Scan dependencies, secrets and IaC misconfigurations in the current folder
    docker run --rm -v "$PWD":/srv -w /srv \
      ghcr.io/jinalshah/devops/images/all-devops:latest \
      trivy fs --scanners vuln,secret,misconfig .
    ```

    Trivy downloads its vulnerability database on first run.

=== ":simple-kubernetes: Kubernetes"

    ```bash
    # Validate manifests against your cluster's API without changing anything
    docker run --rm -v "$PWD":/srv -w /srv \
      -v ~/.kube:/root/.kube \
      ghcr.io/jinalshah/devops/images/all-devops:latest \
      kubectl apply --dry-run=server -f k8s/
    ```

=== ":simple-claude: AI review"

    ```bash
    # One-time: sign in (opens a URL to visit), then /exit
    docker run -it --rm -v ~/.claude:/root/.claude \
      ghcr.io/jinalshah/devops/images/all-devops:latest claude

    # Review a file non-interactively with -p (print mode)
    docker run --rm -v "$PWD":/srv -w /srv \
      -v ~/.claude:/root/.claude \
      ghcr.io/jinalshah/devops/images/all-devops:latest \
      sh -c 'cat main.tf | claude -p "Review this Terraform for security issues"'
    ```

    See [AI CLI setup](tool-basics/ai-cli-setup.md) for Codex, Copilot and Antigravity.

---

## Next steps by use case

=== ":lucide-laptop: Local development"

    Keep a named container around between sessions:

    ```bash
    docker run -it --name devops-work \
      -v "$PWD":/srv -w /srv \
      -v ~/.ssh:/root/.ssh:ro \
      -v ~/.aws:/root/.aws \
      -v ~/.config/gcloud:/root/.config/gcloud \
      -v ~/.claude:/root/.claude \
      ghcr.io/jinalshah/devops/images/all-devops:latest

    # Later
    docker start -ai devops-work
    ```

    Then set up [cloud credentials](use-images/authentication.md) and [AI CLIs](tool-basics/ai-cli-setup.md).

=== ":lucide-workflow: CI/CD"

    ```yaml
    container:
      image: ghcr.io/jinalshah/devops/images/all-devops:1.0.abc1234
    ```

    - **Pin a tag**: `1.0.<short-sha>` tags are per commit. Scheduled rebuilds refresh them with newer tools, so pin a `@sha256:` digest if you need exact bits.
    - **Use CI secrets** for credentials, never baked-in files.
    - Read more in [CI/CD integration](workflows/index.md).

=== ":lucide-shield-check: Security-focused"

    1. Scan code and IaC with `trivy fs` and `trivy config`
    2. Lint with TFLint and ansible-lint
    3. Run `pre-commit` hooks in CI
    4. Pin image digests
    5. Scan the image itself: `trivy image ghcr.io/jinalshah/devops/images/all-devops:latest`

    See the [security-first workflow](workflows/multi-tool-patterns.md#pattern-2-security-first-workflow).

---

## Handy shell aliases

Add these to your `~/.bashrc` or `~/.zshrc`:

```bash
# Interactive shell in the current project
alias devops='docker run -it --rm -v "$PWD":/srv -w /srv -v ~/.ssh:/root/.ssh:ro -v ~/.aws:/root/.aws -v ~/.config/gcloud:/root/.config/gcloud ghcr.io/jinalshah/devops/images/all-devops:latest'

# One-off commands: devops-run terraform plan
alias devops-run='docker run --rm -v "$PWD":/srv -w /srv -v ~/.aws:/root/.aws -v ~/.config/gcloud:/root/.config/gcloud ghcr.io/jinalshah/devops/images/all-devops:latest'
```

---

## Troubleshooting your first run

??? question "`docker: command not found`"

    Install Docker Desktop ([macOS](https://docs.docker.com/desktop/setup/install/mac-install/), [Windows](https://docs.docker.com/desktop/setup/install/windows-install/)) or [Docker Engine on Linux](https://docs.docker.com/engine/install/).

??? question "Cannot connect to the Docker daemon"

    Start Docker Desktop, or on Linux run `sudo systemctl start docker`.

??? question "Permission denied while trying to connect (Linux)"

    ```bash
    sudo usermod -aG docker "$USER"
    # Log out and back in for this to take effect
    ```

??? question "The pull is very slow"

    It's a 1.5 GB+ download, so the first pull takes a while. Use GHCR (no pull rate limits for public images), pick the single-cloud image if you only need one cloud, and it only happens once per update.

??? question "A tool says `command not found`"

    Check you're using the right variant: `aws` isn't in `gcp-devops` and `gcloud` isn't in `aws-devops`. The [tool explorer](use-images/quick-reference.md#tool-explorer) shows which image has what.

More fixes are in [Troubleshooting](troubleshooting/index.md).

---

## Where next?

<div class="grid cards" markdown>

-   :lucide-book-open: [__Tool basics__](tool-basics/index.md)

    A cheat sheet for every tool.

-   :lucide-key-round: [__Authentication__](use-images/authentication.md)

    AWS, GCP, SSH, Git and AI CLIs.

-   :lucide-bot: [__AI CLI setup__](tool-basics/ai-cli-setup.md)

    Claude, Codex, Copilot and Antigravity.

-   :lucide-workflow: [__Workflows__](workflows/index.md)

    CI/CD recipes and multi-tool patterns.

</div>
