# Tool Basics

This page gives quick, practical examples for core tools included in the images.

## Infrastructure as Code

### Terraform

```bash
terraform init
terraform plan
terraform apply
```

### Terragrunt

```bash
terragrunt run-all plan
terragrunt run-all apply
```

### TFLint

```bash
tflint --init
tflint
```

### Packer

```bash
packer init .
packer validate .
packer build .
```

## Kubernetes and Platform

### kubectl

```bash
kubectl config get-contexts
kubectl get pods -A
kubectl logs <pod-name> -n <namespace>
```

### Helm

```bash
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo update
helm list -A
```

### k9s

```bash
k9s
```

## Cloud CLIs

### AWS CLI (`aws-devops` and `all-devops`)

```bash
aws sts get-caller-identity
aws s3 ls
aws ec2 describe-regions
```

### Session Manager Plugin (`aws-devops` and `all-devops`)

```bash
aws ssm start-session --target <instance-id>
```

### Google Cloud CLI (`gcp-devops` and `all-devops`)

```bash
gcloud auth list
gcloud config list
gcloud projects list
```

## Security and Quality

### Trivy

```bash
trivy image ghcr.io/jinalshah/devops/images/all-devops:latest
```

### Ansible and ansible-lint

```bash
ansible --version
ansible-lint playbook.yml
ansible-playbook playbook.yml
```

## Development Utilities

### GitHub CLI

```bash
gh auth status
gh repo view
```

### Taskfile (`task`)

```bash
task --list
task <task-name>
```

## Network and DNS

### DNS tools

```bash
dig google.com
nslookup google.com
```

### ncat and telnet

```bash
ncat --version
ncat google.com 80
telnet google.com 80
```

## AI CLIs

The images install these CLIs:

- `claude`
- `codex`
- `copilot`
- `gemini`

Version checks:

```bash
claude --version
codex --version
copilot --version
gemini --version
```

Most AI CLIs require separate authentication setup before full use.
