# Quick Reference

Fast lookup guide for common DevOps Images commands, volume mounts, and usage patterns.

## Tool explorer

Search every tool in the images and filter by image or category. Hover over a tool to see the command that checks it's installed.

<div class="di-widget" data-di-tools markdown>
!!! note "Interactive explorer"
    This explorer needs JavaScript. Without it, see [Tool Basics](../tool-basics/index.md) for the full list.
</div>

## Images and registries

| Image | GHCR (recommended) | Download |
|-------|--------------------|----------|
| <span class="di-pill di-pill--all">all-devops</span> | `ghcr.io/jinalshah/devops/images/all-devops` | ~1.6 GB |
| <span class="di-pill di-pill--aws">aws-devops</span> | `ghcr.io/jinalshah/devops/images/aws-devops` | ~1.55 GB |
| <span class="di-pill di-pill--gcp">gcp-devops</span> | `ghcr.io/jinalshah/devops/images/gcp-devops` | ~1.5 GB |

The same images are at `registry.gitlab.com/jinal-shah/devops/images/<image>` and `js01/<image>` (Docker Hub). Tags are `latest`, a per-commit `1.0.<sha>` (refreshed by scheduled rebuilds) and `1.0.<sha>-amd64` / `-arm64`. Pin by `@sha256:` digest for strict reproducibility.

## Run

=== ":lucide-terminal: Shell"

    ```bash
    docker run -it --rm -v "$PWD":/srv -w /srv \
      ghcr.io/jinalshah/devops/images/all-devops:latest
    ```

=== ":lucide-play: One command"

    ```bash
    docker run --rm -v "$PWD":/srv -w /srv \
      ghcr.io/jinalshah/devops/images/all-devops:latest \
      terraform plan
    ```

=== ":lucide-briefcase: Full workstation"

    ```bash
    docker run -it --rm \
      -v "$PWD":/srv -w /srv \
      -v ~/.ssh:/root/.ssh:ro \
      -v ~/.aws:/root/.aws \
      -v ~/.config/gcloud:/root/.config/gcloud \
      -v ~/.kube:/root/.kube \
      -v ~/.claude:/root/.claude \
      -v ~/.codex:/root/.codex \
      -v ~/.copilot:/root/.copilot \
      -v ~/.gemini:/root/.gemini \
      ghcr.io/jinalshah/devops/images/all-devops:latest
    ```

## Mounts cheat sheet

| Mount | For | Tools |
|-------|-----|-------|
| `-v "$PWD":/srv -w /srv` | Your project | Everything |
| `-v ~/.ssh:/root/.ssh:ro` | SSH keys | `git`, `ssh`, Ansible |
| `-v ~/.aws:/root/.aws` | AWS profiles and SSO cache | `aws`, Terraform, boto3 |
| `-v ~/.config/gcloud:/root/.config/gcloud` | gcloud accounts and ADC | `gcloud`, `gsutil`, `bq`, GKE, Terraform |
| `-v ~/.kube:/root/.kube` | kubeconfig | `kubectl`, `helm`, `k9s` |
| `-v ~/.claude:/root/.claude` | Claude Code login and settings | `claude` |
| `-v ~/.codex:/root/.codex` | Codex config and `auth.json` | `codex` |
| `-v ~/.copilot:/root/.copilot` | Copilot CLI login and config | `copilot` |
| `-v ~/.gemini:/root/.gemini` | Antigravity CLI settings and login | `agy` |
| `-v ~/.terraform.d:/root/.terraform.d` | Provider cache (with `-e TF_PLUGIN_CACHE_DIR=/root/.terraform.d/plugin-cache`) | Terraform |

## Everyday commands

=== ":simple-terraform: Terraform"

    ```bash
    docker run --rm -v "$PWD":/srv -w /srv -v ~/.aws:/root/.aws \
      ghcr.io/jinalshah/devops/images/all-devops:latest \
      bash -c 'terraform init && terraform plan -out=tfplan'
    ```

=== ":simple-trivy: Scan & lint"

    ```bash
    # IaC misconfigurations
    docker run --rm -v "$PWD":/srv -w /srv \
      ghcr.io/jinalshah/devops/images/all-devops:latest \
      trivy config .

    # TFLint and ansible-lint
    docker run --rm -v "$PWD":/srv -w /srv \
      ghcr.io/jinalshah/devops/images/all-devops:latest \
      bash -c 'tflint --init && tflint --recursive && ansible-lint'
    ```

    Trivy downloads its vulnerability database on the first `trivy image` or `trivy fs` scan.

=== ":simple-kubernetes: Kubernetes"

    ```bash
    # kubectl and Helm
    docker run --rm -v "$PWD":/srv -w /srv -v ~/.kube:/root/.kube \
      ghcr.io/jinalshah/devops/images/all-devops:latest \
      bash -c 'kubectl get pods -A && helm upgrade --install myapp ./charts/myapp'

    # k9s needs a TTY
    docker run -it --rm -v ~/.kube:/root/.kube \
      ghcr.io/jinalshah/devops/images/all-devops:latest k9s
    ```

    For EKS or GKE clusters, also mount `~/.aws` or `~/.config/gcloud`, because the kubeconfig calls the cloud CLI to get tokens.

=== ":lucide-bot: AI agents"

    Always use the non-interactive mode in scripts. Pipe content in with `docker run -i`:

    ```bash
    # Claude Code: pipe a diff into -p (there is no --file flag)
    git diff | docker run --rm -i -v "$PWD":/srv -w /srv -v ~/.claude:/root/.claude \
      ghcr.io/jinalshah/devops/images/all-devops:latest \
      claude -p "Review this diff for security issues"

    # Claude Code: write the answer to a file on the host (needs -p)
    docker run --rm -v "$PWD":/srv -w /srv -v ~/.claude:/root/.claude \
      ghcr.io/jinalshah/devops/images/all-devops:latest \
      claude -p "Write a Terraform module for an AWS VPC. Output only HCL." > vpc.tf

    # Codex, Copilot and Antigravity
    docker run --rm -v "$PWD":/srv -w /srv -v ~/.codex:/root/.codex \
      ghcr.io/jinalshah/devops/images/all-devops:latest \
      codex exec "Explain what main.tf provisions"

    docker run --rm -v "$PWD":/srv -w /srv -v ~/.copilot:/root/.copilot \
      ghcr.io/jinalshah/devops/images/all-devops:latest \
      copilot -p "Summarise the Helm chart in charts/myapp" --allow-all-tools

    docker run --rm -v "$PWD":/srv -w /srv -v ~/.gemini:/root/.gemini \
      ghcr.io/jinalshah/devops/images/all-devops:latest \
      agy -p "List the Kubernetes resources defined in k8s/"
    ```

    Sign in interactively once (`claude` then `/login`, `codex login`, `copilot` then `/login`, `agy`) and the mounted directories keep you signed in. See the [AI CLI setup guide](../tool-basics/ai-cli-setup.md).

## Credentials in CI

=== ":fontawesome-brands-aws: AWS"

    ```bash
    # Pass through variables already set in your shell or CI job
    docker run --rm -v "$PWD":/srv -w /srv \
      -e AWS_ACCESS_KEY_ID -e AWS_SECRET_ACCESS_KEY -e AWS_SESSION_TOKEN \
      -e AWS_DEFAULT_REGION=eu-west-2 \
      ghcr.io/jinalshah/devops/images/all-devops:latest \
      terraform apply -auto-approve
    ```

=== ":simple-googlecloud: Google Cloud"

    ```bash
    # GOOGLE_APPLICATION_CREDENTIALS covers Terraform and client libraries;
    # gcloud itself needs activate-service-account
    docker run --rm -v "$PWD":/srv -w /srv \
      -v /path/to/key.json:/secrets/key.json:ro \
      -e GOOGLE_APPLICATION_CREDENTIALS=/secrets/key.json \
      ghcr.io/jinalshah/devops/images/all-devops:latest \
      bash -c 'gcloud auth activate-service-account --key-file=/secrets/key.json && terraform apply -auto-approve'
    ```

=== ":lucide-bot: AI CLIs"

    ```bash
    # Claude Code: ANTHROPIC_API_KEY (or CLAUDE_CODE_OAUTH_TOKEN from `claude setup-token`)
    docker run --rm -v "$PWD":/srv -w /srv -e ANTHROPIC_API_KEY \
      ghcr.io/jinalshah/devops/images/all-devops:latest \
      claude -p "Review main.tf for security issues"

    # Codex: CODEX_API_KEY for codex exec
    docker run --rm -v "$PWD":/srv -w /srv -e CODEX_API_KEY \
      ghcr.io/jinalshah/devops/images/all-devops:latest \
      codex exec "Review main.tf for security issues"

    # Copilot: fine-grained PAT with the "Copilot Requests" permission
    docker run --rm -v "$PWD":/srv -w /srv -e COPILOT_GITHUB_TOKEN \
      ghcr.io/jinalshah/devops/images/all-devops:latest \
      copilot -p "Review main.tf for security issues" --allow-all-tools
    ```

    `agy` needs `{"modelProvider": "gemini"}` in `~/.gemini/antigravity-cli/settings.json` **and** `GEMINI_API_KEY`; the variable alone isn't enough.

## Aliases

Inside the container, zsh and bash already have shortcuts such as `k` (kubectl), `kg`, `kd`, `kl`, `tf`, `tfi`, `tfp`, `tfa` and `aws-ssm`. On your **host**, these save typing:

```bash
alias devops='docker run -it --rm -v "$PWD":/srv -w /srv -v ~/.ssh:/root/.ssh:ro -v ~/.aws:/root/.aws -v ~/.config/gcloud:/root/.config/gcloud -v ~/.kube:/root/.kube ghcr.io/jinalshah/devops/images/all-devops:latest'

devops                      # interactive shell
devops terraform plan       # one-off command
devops trivy config .
```

## Check versions

```bash
docker run --rm ghcr.io/jinalshah/devops/images/all-devops:latest bash -c '
  terraform version; kubectl version --client; helm version --short
  ansible --version | head -1; aws --version; gcloud --version | head -1
  trivy --version | head -1; python3 --version; node --version'
```

## k9s keys

| Key | Action |
|-----|--------|
| `:` then `pods`, `deploy`, `svc` … | Jump to a resource type |
| `0` | All namespaces |
| `/` | Filter |
| `d` | Describe |
| `l` | Logs |
| `s` | Shell into the container |
| ++ctrl+c++ or `:q` | Quit |

## Quick fixes

??? question "A pull fails or is slow"
    Try another registry: `registry.gitlab.com/jinal-shah/devops/images/all-devops:latest` or `js01/all-devops:latest`. Docker Hub rate-limits anonymous pulls.

??? question "Files in my project are owned by root"
    Add `--user "$(id -u):$(id -g)"` for commands that don't write to `HOME`, or run `sudo chown -R "$(id -u):$(id -g)" .` afterwards.

??? question "Credentials aren't picked up"
    Check that the mount landed: `docker run --rm -v ~/.aws:/root/.aws ghcr.io/jinalshah/devops/images/all-devops:latest ls -la /root/.aws`. Then test with `aws sts get-caller-identity` or `gcloud auth list`.

## Next steps

- [Authentication guide](authentication.md)
- [Docker Compose examples](docker-compose.md)
- [Tool basics](../tool-basics/index.md)
- [Workflows & patterns](../workflows/index.md)
