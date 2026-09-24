# Tool Basics

A quick, practical reference for every tool in the images: what it's for, which image has it, and the commands you'll reach for most.

:lucide-search: Want to search and filter the full list instead? Open the [interactive tool explorer](../use-images/quick-reference.md#tool-explorer).

<div class="grid cards" markdown>

-   :simple-terraform:{ .lg .middle } __Infrastructure as code__

    ---

    Terraform (via tfswitch), Terragrunt, TFLint, Packer

    [:octicons-arrow-right-24: IaC tools](#iac)

-   :simple-kubernetes:{ .lg .middle } __Kubernetes__

    ---

    kubectl, Helm 3, k9s

    [:octicons-arrow-right-24: Kubernetes tools](#kubernetes)

-   :lucide-cloud:{ .lg .middle } __Cloud CLIs__

    ---

    AWS CLI v2 + Session Manager, Google Cloud CLI + GKE auth plugin

    [:octicons-arrow-right-24: Cloud CLIs](#cloud-clis)

-   :simple-ansible:{ .lg .middle } __Automation__

    ---

    Ansible, ansible-lint, pre-commit, Task, make

    [:octicons-arrow-right-24: Automation tools](#automation)

-   :simple-trivy:{ .lg .middle } __Security__

    ---

    Trivy for images, filesystems, IaC and secrets

    [:octicons-arrow-right-24: Trivy](#security)

-   :simple-github:{ .lg .middle } __Git & collaboration__

    ---

    Git, GitHub CLI (`gh`), ghorg

    [:octicons-arrow-right-24: Git tools](#git)

-   :simple-python:{ .lg .middle } __Languages__

    ---

    Python 3.14 with pip packages, Node.js LTS with npm and npx

    [:octicons-arrow-right-24: Languages](#languages)

-   :lucide-bot:{ .lg .middle } __AI coding agents__

    ---

    Claude Code, OpenAI Codex CLI, GitHub Copilot CLI, Antigravity CLI (`agy`)

    [:octicons-arrow-right-24: AI CLIs](#ai-clis)

-   :lucide-database:{ .lg .middle } __Database clients__

    ---

    mongosh, psql 17, mysql 8.4

    [:octicons-arrow-right-24: Databases](#databases)

-   :lucide-network:{ .lg .middle } __Network & diagnostics__

    ---

    dig, nmap, ncat, telnet, curl, wget, lftp, openssl, ssh

    [:octicons-arrow-right-24: Network tools](#network)

-   :lucide-square-terminal:{ .lg .middle } __Shells & aliases__

    ---

    Zsh (Oh My Zsh, default), Bash, Fish, plus handy `tf*` and `k*` aliases

    [:octicons-arrow-right-24: Shells](#shells)

-   :lucide-wrench:{ .lg .middle } __Everyday utilities__

    ---

    jq, zip/unzip, tar, vim, less, tree, bubblewrap

    [:octicons-arrow-right-24: Utilities](#utilities)

</div>

## Which image has what?

Every tool on this page is in all three images unless its **Available in** line says otherwise. Only the cloud layers differ:

| Tool | <span class="di-pill di-pill--all">all-devops</span> | <span class="di-pill di-pill--aws">aws-devops</span> | <span class="di-pill di-pill--gcp">gcp-devops</span> |
|------|:---:|:---:|:---:|
| Shared base (everything else on this page) | :material-check: | :material-check: | :material-check: |
| AWS CLI v2, Session Manager plugin | :material-check: | :material-check: | |
| boto3, cfn-lint, s3cmd, crcmod, pytest, requests, bs4, lxml | :material-check: | :material-check: | |
| Google Cloud CLI (`gcloud`, `gsutil`, `bq`) | :material-check: | | :material-check: |
| gcloud components: `beta`, `docker-credential-gcr`, `gke-gcloud-auth-plugin` | :material-check: | | :material-check: |

!!! info "Not in the images"
    These are sometimes assumed but are **not** installed, so add them yourself if you need them: the Docker CLI or daemon (no Docker-in-Docker), standalone `kustomize` (use `kubectl kustomize` or `kubectl apply -k`), `yq`, `pipx`, `terraform-docs`, `redis-cli`, Go, Java and `gcloud alpha`.

---

## Infrastructure as code { #iac }

### Terraform

Declarative infrastructure provisioning for any cloud.

**Available in:** <span class="di-pill di-pill--base">all three images</span> · latest release at build time, installed with `tfswitch`

=== "Basics"

    ```bash
    terraform init        # download providers and modules
    terraform fmt -recursive
    terraform validate
    terraform plan
    terraform apply
    terraform destroy
    terraform output
    ```

=== "Advanced"

    ```bash
    # Workspaces
    terraform workspace new staging
    terraform workspace select staging

    # Variable files and non-interactive apply (CI)
    terraform plan -var-file="prod.tfvars" -out=tfplan
    terraform apply tfplan

    # Target a single resource
    terraform apply -target=aws_instance.example

    # Bring existing infrastructure under management
    terraform import aws_instance.example i-1234567890abcdef0
    ```

=== "Switch versions (tfswitch)"

    ```bash
    # Install and use the latest release
    tfswitch --latest

    # Install and use a specific version
    tfswitch 1.9.8

    # With no argument, tfswitch reads .terraform-version or
    # the required_version constraint in your .tf files
    tfswitch
    ```

!!! tip "Shortcuts"
    The shells ship with `tf`, `tfi`, `tfp`, `tfa`, `tfd`, `tff`, `tfv` and `tfo` aliases. See [shell aliases](#aliases).

### Terragrunt

A thin wrapper around Terraform for DRY configuration, remote state and multi-module stacks.

**Available in:** <span class="di-pill di-pill--base">all three images</span> · pinned per build, bumped automatically

=== "Basics"

    ```bash
    # Single module (Terraform commands pass straight through)
    terragrunt init
    terragrunt plan
    terragrunt apply

    # Every module under the current directory
    terragrunt run --all plan
    terragrunt run --all apply
    terragrunt run --all destroy
    ```

=== "Advanced"

    ```bash
    # Skip interactive prompts (CI)
    terragrunt run --all apply --non-interactive

    # Include dependencies that live outside the current directory
    terragrunt run --all apply --queue-include-external

    # Validate every module
    terragrunt run --all validate

    # Show the dependency graph (DOT format)
    terragrunt dag graph
    ```

!!! warning "Old commands are gone"
    Recent Terragrunt releases replaced the old CLI. `run-all` is now `run --all`, `--terragrunt-non-interactive` is `--non-interactive`, `graph-dependencies` is `dag graph`, and `--terragrunt-include-external-dependencies` is `--queue-include-external`.

### TFLint

A Terraform linter that catches errors, deprecated syntax and provider-specific mistakes before `plan`.

**Available in:** <span class="di-pill di-pill--base">all three images</span> · pinned per build, bumped automatically

```bash
tflint --init                    # install the plugins listed in .tflint.hcl
tflint                           # lint the current directory
tflint --recursive               # lint every module below here
tflint --config=.tflint.hcl
tflint --format=compact          # also: json, checkstyle, junit, sarif
tflint --enable-rule=terraform_naming_convention
```

### Packer

Builds machine images (AMIs, GCE images and more) from one template.

**Available in:** <span class="di-pill di-pill--base">all three images</span> · pinned per build, bumped automatically

=== "Basics"

    ```bash
    packer init .        # install required plugins
    packer fmt .
    packer validate .
    packer build .
    packer build -var-file="variables.pkrvars.hcl" .
    ```

=== "Advanced"

    ```bash
    # Build only one source
    packer build -only=amazon-ebs.ubuntu .

    # Override variables on the command line
    packer build -var 'region=eu-west-2' -var 'instance_type=t3.micro' .

    # Step through the build, or replace existing artefacts
    packer build -debug .
    packer build -force .
    ```

!!! note
    Packer's `docker` builder needs a Docker daemon, which the images don't include. Cloud builders such as `amazon-ebs` and `googlecompute` work fine.

---

## Kubernetes { #kubernetes }

### kubectl

The Kubernetes command-line client.

**Available in:** <span class="di-pill di-pill--base">all three images</span> · latest stable release at build time, installed at `/usr/local/bin/kubectl`

=== "Basics"

    ```bash
    kubectl config get-contexts
    kubectl config use-context my-cluster
    kubectl cluster-info

    kubectl get pods -A
    kubectl get deployments,services
    kubectl describe pod <pod-name>
    kubectl logs <pod-name> -f
    kubectl exec -it <pod-name> -- /bin/sh
    ```

=== "Advanced"

    ```bash
    # Apply manifests (a file, a directory, or a kustomization)
    kubectl apply -f deployment.yaml
    kubectl apply -f ./manifests/
    kubectl apply -k ./overlays/prod
    kubectl kustomize ./overlays/prod    # render without applying

    # Day-2 operations
    kubectl scale deployment/nginx --replicas=5
    kubectl rollout status deployment/nginx
    kubectl rollout undo deployment/nginx
    kubectl port-forward svc/nginx 8080:80

    # Needs metrics-server in the cluster
    kubectl top nodes

    kubectl get events --sort-by='.lastTimestamp'
    ```

=== "Connect to a cluster"

    ```bash
    # Reuse your host kubeconfig
    docker run -it --rm -v ~/.kube:/root/.kube \
      ghcr.io/jinalshah/devops/images/all-devops:latest

    # EKS (aws-devops, all-devops)
    aws eks update-kubeconfig --name my-cluster --region eu-west-2

    # GKE (gcp-devops, all-devops): uses the bundled gke-gcloud-auth-plugin
    gcloud container clusters get-credentials my-cluster --region europe-west2
    ```

!!! tip "Shortcuts"
    `k`, `kg`, `kd`, `kl`, `ka` and `kr` are aliases for `kubectl`, `get`, `describe`, `logs`, `apply` and `run`, and kubectl tab-completion is enabled in Zsh and Bash.

### Helm

The Kubernetes package manager.

**Available in:** <span class="di-pill di-pill--base">all three images</span> · latest Helm 3 release at build time

=== "Basics"

    ```bash
    helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
    helm repo update
    helm search repo prometheus

    helm install monitoring prometheus-community/kube-prometheus-stack \
      --namespace monitoring --create-namespace
    helm list -A
    helm upgrade monitoring prometheus-community/kube-prometheus-stack -n monitoring
    helm uninstall monitoring -n monitoring
    ```

=== "Advanced"

    ```bash
    # Inspect and override values
    helm show values prometheus-community/prometheus > values.yaml
    helm install prom prometheus-community/prometheus -f values.yaml
    helm install prom prometheus-community/prometheus --set server.replicaCount=2

    # Render locally or preview an install
    helm template prom prometheus-community/prometheus -f values.yaml
    helm install prom prometheus-community/prometheus --dry-run --debug

    # History and rollback
    helm history prom
    helm rollback prom 1

    # Author your own chart
    helm create my-chart
    helm lint my-chart
    helm package my-chart
    ```

!!! warning "The `stable` repo is gone"
    `https://charts.helm.sh/stable` was deprecated years ago and no longer receives updates. Use the project's own chart repository (for example `prometheus-community`) or an OCI registry instead.

### k9s

A terminal UI for watching and managing Kubernetes clusters.

**Available in:** <span class="di-pill di-pill--base">all three images</span> · pinned per build, bumped automatically

```bash
k9s                        # current context
k9s -n kube-system         # start in a namespace
k9s --context my-cluster
k9s --readonly             # disable modifying commands
```

Inside k9s, type `:pods`, `:svc`, `:deploy` or `:ns` to switch views, `/` to filter, ++l++ for logs, ++d++ to describe, ++e++ to edit, `?` for help and ++ctrl+c++ to quit.

---

## Cloud CLIs { #cloud-clis }

### AWS CLI v2

**Available in:** <span class="di-pill di-pill--all">all-devops</span> <span class="di-pill di-pill--aws">aws-devops</span>

=== "Basics"

    ```bash
    aws sts get-caller-identity        # who am I?
    aws configure                      # access keys
    aws configure sso                  # IAM Identity Center
    aws sso login --profile my-profile

    aws s3 ls
    aws ec2 describe-instances --output table
    ```

=== "Advanced"

    ```bash
    # S3
    aws s3 cp file.txt s3://my-bucket/
    aws s3 sync ./site s3://my-bucket/site --delete

    # Filter and project with JMESPath
    aws ec2 describe-instances \
      --filters "Name=instance-state-name,Values=running" \
      --query 'Reservations[].Instances[].[InstanceId,Tags[?Key==`Name`]|[0].Value]' \
      --output table

    # CloudFormation (lint templates first with cfn-lint)
    cfn-lint template.yaml
    aws cloudformation deploy --stack-name my-stack --template-file template.yaml

    # SSM Parameter Store
    aws ssm get-parameter --name /my/parameter --with-decryption

    # Per-command profile and region
    aws s3 ls --profile production --region eu-west-2
    ```

The AWS layer also adds `s3cmd`, and the Python packages `boto3`, `cfn-lint`, `crcmod`, `pytest`, `requests`, `bs4` and `lxml`. `aws` tab-completion is enabled in Zsh and Bash.

### AWS Session Manager plugin

Shell access and port forwarding to EC2 instances without SSH keys or bastion hosts.

**Available in:** <span class="di-pill di-pill--all">all-devops</span> <span class="di-pill di-pill--aws">aws-devops</span>

```bash
# Interactive shell (the aws-ssm alias does the same thing)
aws ssm start-session --target i-1234567890abcdef0
aws-ssm i-1234567890abcdef0

# Forward local port 8080 to port 80 on the instance
aws ssm start-session --target i-1234567890abcdef0 \
  --document-name AWS-StartPortForwardingSession \
  --parameters '{"portNumber":["80"],"localPortNumber":["8080"]}'
```

!!! tip
    The plugin listens on the container's own `localhost`, so publishing the port with `docker run -p` may not reach it from your host. Use the forwarded port from inside the container, or try `--network host` on Linux. To reach RDS or other private endpoints, use `AWS-StartPortForwardingSessionToRemoteHost` and add `"host":["..."]` to the parameters.

### Google Cloud CLI

`gcloud`, `gsutil` and `bq`, plus the `beta`, `docker-credential-gcr` and `gke-gcloud-auth-plugin` components. The SDK lives in `/usr/lib/google-cloud-sdk`.

**Available in:** <span class="di-pill di-pill--all">all-devops</span> <span class="di-pill di-pill--gcp">gcp-devops</span>

=== "Basics"

    ```bash
    gcloud auth login                         # user login (prints a URL in a container)
    gcloud auth application-default login     # ADC for Terraform and client libraries
    gcloud auth list
    gcloud config set project my-project-id
    gcloud config list

    gcloud projects list
    gcloud compute instances list
    ```

=== "Advanced"

    ```bash
    # Service account (gcloud itself ignores GOOGLE_APPLICATION_CREDENTIALS)
    gcloud auth activate-service-account --key-file=/secrets/sa.json

    # Cloud Storage
    gcloud storage buckets create gs://my-bucket --location=europe-west2
    gcloud storage cp file.txt gs://my-bucket/
    gsutil ls gs://my-bucket/

    # BigQuery
    bq ls
    bq query --use_legacy_sql=false 'SELECT 1'

    # Named configurations
    gcloud config configurations create production
    gcloud config configurations activate production
    ```

=== "GKE"

    ```bash
    gcloud container clusters list
    gcloud container clusters get-credentials my-cluster --region europe-west2
    kubectl get nodes

    # The auth plugin that kubectl calls behind the scenes
    gke-gcloud-auth-plugin --version
    ```

!!! success "GKE works out of the box"
    The `gke-gcloud-auth-plugin` component is installed, so `gcloud container clusters get-credentials` writes a working kubeconfig and `kubectl`, `helm` and `k9s` can talk to GKE straight away.

!!! note
    `gcloud alpha` commands are not installed. `gcloud beta` is.

---

## Automation { #automation }

### Ansible

Agentless configuration management and orchestration with YAML playbooks.

**Available in:** <span class="di-pill di-pill--base">all three images</span> · installed with pip, alongside `jmespath` (for `json_query`) and `paramiko`

=== "Basics"

    ```bash
    ansible --version
    ansible all -i inventory.ini -m ping
    ansible webservers -i inventory.ini -a "uptime"

    ansible-playbook -i inventory.ini playbook.yml
    ansible-playbook playbook.yml --syntax-check
    ansible-playbook playbook.yml --check --diff    # dry run
    ```

=== "Advanced"

    ```bash
    ansible-playbook playbook.yml -e "version=1.2.3 env=production"
    ansible-playbook playbook.yml --limit webserver01
    ansible-playbook playbook.yml --tags "configure,deploy" --skip-tags "tests"
    ansible-playbook playbook.yml -vvv

    # Secrets
    ansible-vault encrypt secrets.yml
    ansible-playbook playbook.yml --ask-vault-pass

    # Collections
    ansible-galaxy collection install -r requirements.yml
    ```

!!! tip
    Mount your SSH keys read-only (`-v ~/.ssh:/root/.ssh:ro`) so Ansible can reach your hosts.

### ansible-lint

Checks playbooks and roles against best practices. `yamllint` is installed with it as a dependency, so you can run it directly too.

**Available in:** <span class="di-pill di-pill--base">all three images</span>

```bash
ansible-lint                    # lint the current project
ansible-lint playbook.yml
ansible-lint -L                 # list rules
ansible-lint --fix              # apply automatic fixes

# Skip rules by name
ansible-lint -x command-instead-of-module,no-changed-when playbook.yml

yamllint .
```

!!! warning
    Numeric rule IDs such as `301` and `302` were removed. Use rule names (`command-instead-of-module`, `no-changed-when` and so on), either with `-x` or in `.ansible-lint`.

### pre-commit

Runs linters and formatters as Git hooks.

**Available in:** <span class="di-pill di-pill--base">all three images</span>

```bash
pre-commit install               # add the hook to .git/hooks
pre-commit run --all-files
pre-commit run terraform_fmt --all-files   # one hook, by id
pre-commit autoupdate
pre-commit uninstall
```

### Task (go-task) and make

Task is a YAML-based task runner; GNU `make` is there too.

**Available in:** <span class="di-pill di-pill--base">all three images</span> · Task is the latest release at build time

=== "Commands"

    ```bash
    task --list          # or task -l
    task plan
    task fmt validate    # run several tasks
    task apply ENV=prod  # pass a variable

    make plan
    ```

=== "Example Taskfile.yml"

    ```yaml
    version: '3'

    vars:
      ENV: dev

    tasks:
      fmt:
        desc: Format Terraform code
        cmds:
          - terraform fmt -recursive

      validate:
        desc: Validate Terraform
        cmds:
          - terraform validate

      plan:
        desc: Plan for an environment
        cmds:
          - terraform plan -var-file=envs/{{.ENV}}.tfvars

      apply:
        desc: Apply for an environment
        deps: [validate]
        cmds:
          - terraform apply -var-file=envs/{{.ENV}}.tfvars
    ```

---

## Security { #security }

### Trivy

Scans container images, filesystems, repositories and IaC for vulnerabilities, misconfigurations and secrets.

**Available in:** <span class="di-pill di-pill--base">all three images</span> · installed from Aqua's yum repository

=== "Basics"

    ```bash
    trivy image nginx:latest
    trivy fs .                         # vulnerabilities in lock files, plus secrets
    trivy config ./terraform/          # IaC misconfigurations
    trivy fs --scanners secret .
    trivy repo https://github.com/jinalshah/devops-images
    ```

=== "Advanced"

    ```bash
    # Fail CI on serious findings only
    trivy image --severity HIGH,CRITICAL --exit-code 1 --ignore-unfixed nginx:latest

    # Output formats
    trivy image --format json -o results.json nginx:latest
    trivy image --format sarif -o results.sarif nginx:latest

    # Custom Rego checks for IaC
    trivy config --config-check ./checks ./terraform/

    # Compliance report
    trivy image --compliance docker-cis-1.6.0 nginx:latest

    # Clear caches and the downloaded databases
    trivy clean --all
    ```

!!! info "First scan downloads the database"
    No vulnerability database is baked into the image, so the first scan in a fresh container downloads it. Mount a cache to reuse it: `-v ~/.cache/trivy:/root/.cache/trivy`.

!!! tip "No Docker daemon needed"
    There is no Docker in the image, so `trivy image` pulls the image straight from the registry. For private registries, log in with `trivy registry login` or set `TRIVY_USERNAME` and `TRIVY_PASSWORD`.

---

## Git and collaboration { #git }

### Git

**Available in:** <span class="di-pill di-pill--base">all three images</span>

```bash
git clone git@github.com:owner/repo.git
git switch -c feature/my-change
git add -p
git commit -m "Describe the change"
git push -u origin feature/my-change
git log --oneline --graph -20
```

!!! tip
    Mount `~/.ssh:/root/.ssh:ro` and `~/.gitconfig:/root/.gitconfig:ro` so commits carry your identity and SSH remotes work.

### GitHub CLI (`gh`)

**Available in:** <span class="di-pill di-pill--base">all three images</span>

=== "Basics"

    ```bash
    gh auth login          # or export GH_TOKEN=...
    gh auth status
    gh repo clone owner/repo
    gh pr list
    gh pr create --fill
    gh pr view 123 --web
    gh issue list
    ```

=== "Advanced"

    ```bash
    gh pr checkout 123
    gh pr review 123 --approve
    gh pr merge 123 --squash --delete-branch

    # GitHub Actions
    gh workflow list
    gh workflow run image-builder.yml
    gh run watch

    # Releases and raw API calls
    gh release create v1.0.0 --generate-notes
    gh api /users/jinalshah/packages/container/devops%2Fimages%2Fall-devops/versions --jq '.[0].metadata.container.tags'
    ```

### ghorg

Clones every repository in a GitHub organisation or user account (GitLab, Bitbucket and Gitea too).

**Available in:** <span class="di-pill di-pill--base">all three images</span> · pinned per build, bumped automatically

```bash
export GHORG_GITHUB_TOKEN=ghp_or_fine_grained_token

ghorg clone my-org
ghorg clone my-username --clone-type=user
ghorg clone my-org --protocol=ssh
ghorg clone my-org --path=/srv/repos

# Running the same clone again pulls updates into existing clones
ghorg clone my-org

ghorg ls
```

A sample config is pre-installed at `~/.config/ghorg/conf.yaml`. `ghorg reclone` runs named clone commands that you define in `~/.config/ghorg/reclone.yaml`; it isn't a "refresh" command.

---

## Languages { #languages }

### Python 3.14

Python 3.14.7 is compiled from source and set as the default `python3`.

**Available in:** <span class="di-pill di-pill--base">all three images</span>

| Pip package | Available in |
|-------------|--------------|
| `ansible`, `ansible-lint` (with `yamllint`), `jmespath`, `paramiko`, `pre-commit` | <span class="di-pill di-pill--base">all three images</span> |
| `zensical`, `mkdocs-material` (documentation sites) | <span class="di-pill di-pill--base">all three images</span> |
| `boto3`, `cfn-lint`, `s3cmd`, `crcmod`, `pytest`, `requests`, `bs4`, `lxml` | <span class="di-pill di-pill--all">all-devops</span> <span class="di-pill di-pill--aws">aws-devops</span> |

```bash
python3 --version
python3 -m pip list
python3 -m pip install -r requirements.txt

# Virtual environments
python3 -m venv .venv
source .venv/bin/activate

# Preview a Zensical docs site from the container
zensical serve -a 0.0.0.0:8000
```

!!! warning "Use `python3 -m pip`"
    A bare `pip` may belong to the distribution's own Python rather than 3.14. `python3 -m pip` always installs into the interpreter you'll run.

!!! note
    For `zensical serve`, publish the port (`docker run -p 8000:8000 ...`) and bind to `0.0.0.0` as shown so your browser can reach it.

### Node.js LTS

The current Node.js LTS release from NodeSource (not pinned to a major version), with `npm` and `npx`.

**Available in:** <span class="di-pill di-pill--base">all three images</span>

```bash
node --version
npm --version

npm ci                # install from package-lock.json
npm run build
npx some-cli --help   # run a package without installing it globally
```

---

## AI coding agents { #ai-clis }

All four are agentic coding assistants: they read and edit files and run commands, interactively or from scripts. Each needs its own account or API key. For full setup, see [AI CLI setup](ai-cli-setup.md).

**Available in:** <span class="di-pill di-pill--base">all three images</span>

| CLI | Command | Sign in | Script or CI | Mount to keep the login |
|-----|---------|---------|--------------|-------------------------|
| :simple-claude: Claude Code | `claude` | `/login` inside `claude` | `claude -p "..."` with `ANTHROPIC_API_KEY` | `~/.claude` |
| :lucide-bot: OpenAI Codex CLI | `codex` | `codex login` | `codex exec "..."` with `CODEX_API_KEY` | `~/.codex` |
| :simple-githubcopilot: GitHub Copilot CLI | `copilot` | `/login` inside `copilot` | `copilot -p "..." --allow-all-tools` with `COPILOT_GITHUB_TOKEN` | `~/.copilot` |
| :simple-googlegemini: Antigravity CLI | `agy` | Google sign-in on first run | `agy -p "..."` | `~/.gemini` |

=== ":simple-claude: Claude Code"

    ```bash
    claude                                   # interactive; run /login the first time
    claude -p "Explain what main.tf creates"
    git diff | claude -p "Review this diff for security issues"
    cat plan.txt | claude -p "Summarise this Terraform plan" --output-format json
    claude -c                                # continue the last conversation
    ```

    There is no `--file` flag: pipe content in, or name the path in the prompt. Always use `-p` in scripts, because without it `claude` opens the interactive UI.

=== ":lucide-bot: Codex CLI"

    ```bash
    codex                                    # interactive
    codex login                              # ChatGPT sign-in
    codex login --device-auth                # headless sign-in
    printenv OPENAI_API_KEY | codex login --with-api-key
    codex exec "Add input validation to scripts/deploy.sh"
    codex exec --json "List the Terraform modules in this repo"
    ```

=== ":simple-githubcopilot: Copilot CLI"

    ```bash
    copilot                                  # interactive; run /login the first time
    export COPILOT_GITHUB_TOKEN=github_pat_...   # fine-grained PAT with "Copilot Requests"
    copilot -p "Write a Makefile target that runs tflint" --allow-all-tools
    ```

    This is the standalone agentic Copilot CLI, not the old `gh copilot` extension. Classic `ghp_` tokens aren't supported.

=== ":simple-googlegemini: Antigravity CLI"

    ```bash
    agy                                      # interactive; prints a sign-in URL, paste the code back
    agy -p "Explain this Helm chart"
    git diff | agy -p "Review this diff"
    agy -p "Summarise the repo" --output-format json --print-timeout 5m
    agy --version
    ```

    Antigravity CLI replaces Google's Gemini CLI. For headless use with a Gemini API key, set `{"modelProvider": "gemini"}` in `~/.gemini/antigravity-cli/settings.json` **and** export `GEMINI_API_KEY`; the variable alone isn't enough.

Mount the config directories to keep logins between runs:

```bash
docker run -it --rm \
  -v "$PWD":/srv -w /srv \
  -v ~/.claude:/root/.claude \
  -v ~/.codex:/root/.codex \
  -v ~/.copilot:/root/.copilot \
  -v ~/.gemini:/root/.gemini \
  ghcr.io/jinalshah/devops/images/all-devops:latest
```

!!! danger "Treat these directories like passwords"
    They hold OAuth tokens and API keys. Don't bake them into images or commit them, and prefer environment variables from your CI secret store in pipelines.

---

## Database clients { #databases }

**Available in:** <span class="di-pill di-pill--base">all three images</span>

=== ":simple-postgresql: psql 17"

    ```bash
    psql -h db.example.com -U app -d appdb
    psql "postgresql://app@db.example.com:5432/appdb?sslmode=require"
    psql -h db.example.com -U app -d appdb -c "SELECT version();"
    psql -h db.example.com -U app -d appdb -f migration.sql
    ```

    Inside `psql`: `\l` lists databases, `\c db` connects, `\dt` lists tables, `\d table` describes one, `\q` quits.

=== ":simple-mysql: MySQL 8.4 client"

    ```bash
    mysql -h db.example.com -u app -p appdb
    mysql -h db.example.com -u app -p -e "SHOW DATABASES;"
    mysql -h db.example.com -u app -p appdb < script.sql
    mysqldump -h db.example.com -u app -p appdb > backup.sql
    ```

=== ":simple-mongodb: mongosh"

    ```bash
    mongosh "mongodb+srv://cluster0.example.mongodb.net/mydb" --username app
    mongosh "mongodb://app@db.example.com:27017/mydb" --eval "db.stats()"
    ```

    Inside `mongosh`: `show dbs`, `use mydb`, `show collections`, `db.users.find({ active: true })`.

!!! tip "Reaching a database on your host"
    From a container, `localhost` is the container itself. Use `host.docker.internal` on Docker Desktop, or run with `--network host` on Linux.

---

## Network and diagnostics { #network }

**Available in:** <span class="di-pill di-pill--base">all three images</span>

=== "DNS"

    ```bash
    dig example.com
    dig example.com MX +short
    dig @8.8.8.8 example.com
    dig -x 8.8.8.8
    dig example.com +trace
    nslookup example.com
    host example.com
    ```

=== "Ports and connectivity"

    ```bash
    # Is one TCP port open?
    ncat -zv db.example.com 5432
    telnet db.example.com 5432

    # Scan a range of ports
    nmap -p 20-100 host.example.com
    nmap -sT -p 443,8443 host.example.com

    ping -c 3 example.com
    ```

=== "HTTP and TLS"

    ```bash
    curl -sSfL https://example.com -o page.html
    curl -s https://api.github.com/repos/jinalshah/devops-images | jq '.stargazers_count'
    wget -c https://example.com/large-file.zip   # resume a download

    # Inspect a certificate
    openssl s_client -connect example.com:443 -servername example.com </dev/null \
      | openssl x509 -noout -subject -issuer -dates
    ```

=== "File transfer and SSH"

    ```bash
    lftp -u user sftp://files.example.com     # FTP, FTPS, SFTP client with mirroring
    ssh user@host.example.com
    scp ./file.txt user@host.example.com:/tmp/
    ```

!!! warning "ncat can't scan ranges"
    `ncat -zv host 20-100` does not scan ports 20 to 100. Use `ncat -zv host 443` for a single port and `nmap -p 20-100 host` for a range.

---

## Shells and aliases { #shells }

**Available in:** <span class="di-pill di-pill--base">all three images</span>

- **Zsh** is the default shell (`CMD ["/bin/zsh"]`), with Oh My Zsh and the `candy` theme. The prompt looks like `root@<host> [HH:MM:SS] [/srv]` followed by `-> #` (Zsh shows `#` because you're root).
- **Bash** has a coloured prompt and bash-completion. Start it with `bash`, or run one-off commands with `docker run ... bash -c "..."`.
- **Fish** is installed but not configured; start it with `fish`.

### Shell aliases { #aliases }

These are defined in both `~/.zshrc` and `~/.bashrc` (from `scripts/10-zshrc.sh` and `scripts/20-bashrc.sh`). Fish has none of them.

| Alias | Expands to | | Alias | Expands to |
|-------|-----------|-|-------|-----------|
| `tf` | `terraform` | | `k` | `kubectl` |
| `tfi` | `terraform init` | | `ka` | `kubectl apply` |
| `tfp` | `terraform plan` | | `kd` | `kubectl describe` |
| `tfa` | `terraform apply` | | `kg` | `kubectl get` |
| `tfd` | `terraform destroy` | | `kl` | `kubectl logs` |
| `tff` | `terraform fmt -recursive` | | `kr` | `kubectl run` |
| `tfv` | `terraform validate` | | `aws-ssm` | `aws ssm start-session --target` |
| `tfo` | `terraform output` | | `ll` / `la` / `l` | `ls -alF` / `ls -A` / `ls -CF` |

Both shells also enable tab-completion for `kubectl`, and for `aws` in the images that include the AWS CLI.

!!! note
    Aliases only exist in interactive shells. In `docker run ... <command>` or CI steps, use the full command names.

---

## Everyday utilities { #utilities }

**Available in:** <span class="di-pill di-pill--base">all three images</span>

=== ":lucide-file-json: jq"

    ```bash
    echo '{"name":"web","replicas":3}' | jq .
    jq -r '.resources[].type' terraform.tfstate
    kubectl get pods -o json | jq -r '.items[] | select(.status.phase != "Running") | .metadata.name'
    aws ec2 describe-regions | jq -r '.Regions[].RegionName'
    ```

=== ":lucide-archive: Archives"

    ```bash
    zip -r build.zip dist/
    unzip -l build.zip
    unzip build.zip -d /tmp/build

    tar -czf backup.tar.gz ./configs
    tar -tzf backup.tar.gz
    tar -xzf backup.tar.gz -C /tmp
    ```

=== ":lucide-folder-tree: Files and editing"

    ```bash
    tree -L 2
    tree -a -I '.git|.terraform'
    less terraform.log
    vim main.tf
    ```

=== ":lucide-shield: bubblewrap"

    ```bash
    # Unprivileged sandboxing; Claude Code's Linux sandbox relies on it
    bwrap --version
    ```

    Running `bwrap` inside a container usually needs extra privileges (user namespaces), so don't expect sandbox modes to work in a default `docker run`.

---

## Next steps

[:lucide-bot: AI CLI setup](ai-cli-setup.md){ .md-button .md-button--primary }
[:lucide-key-round: Authentication](../use-images/authentication.md){ .md-button }
[:lucide-life-buoy: Troubleshooting](../troubleshooting/index.md){ .md-button }
