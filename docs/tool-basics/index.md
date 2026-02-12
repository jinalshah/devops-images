# Tool Basics

This comprehensive guide covers all tools included in the images, from basic to advanced usage. Each tool includes a description, common use cases, and practical examples.

---

## Infrastructure as Code (IaC)

### Terraform

**What it does:** Terraform is an infrastructure as code tool that lets you define and provision infrastructure across cloud providers using declarative configuration files.

**Available in:** All images

**Common use cases:**
- Provisioning cloud infrastructure (VMs, networks, storage)
- Managing Kubernetes clusters
- Multi-cloud deployments
- Infrastructure versioning and collaboration

**Basic usage:**

```bash
# Initialize Terraform working directory
terraform init

# Validate configuration files
terraform validate

# Preview changes without applying
terraform plan

# Apply changes to infrastructure
terraform apply

# Destroy managed infrastructure
terraform destroy

# Format configuration files
terraform fmt

# Show current state
terraform show
```

**Advanced usage:**

```bash
# Use a specific workspace
terraform workspace select production
terraform workspace new staging

# Plan with variable file
terraform plan -var-file="prod.tfvars"

# Apply with auto-approval (CI/CD)
terraform apply -auto-approve

# Target specific resources
terraform apply -target=aws_instance.example

# Import existing infrastructure
terraform import aws_instance.example i-1234567890abcdef0
```

**Switching Terraform versions:**

The images include `tfswitch` for managing Terraform versions:

```bash
# Install and use latest Terraform version
tfswitch --latest

# Install specific version
tfswitch 1.7.0

# Use version from .terraform-version file
tfswitch
```

---

### Terragrunt

**What it does:** Terragrunt is a thin wrapper for Terraform that provides extra tools for keeping configurations DRY, managing remote state, and working with multiple modules.

**Available in:** All images

**Common use cases:**
- Managing multiple Terraform modules
- Keeping backend configuration DRY
- Executing commands across multiple modules
- Managing dependencies between modules

**Basic usage:**

```bash
# Initialize with Terragrunt
terragrunt init

# Plan across all modules
terragrunt run-all plan

# Apply across all modules
terragrunt run-all apply

# Destroy across all modules
terragrunt run-all destroy
```

**Advanced usage:**

```bash
# Run plan with specific terragrunt variables
terragrunt plan --terragrunt-non-interactive

# Execute across modules with dependency awareness
terragrunt run-all apply --terragrunt-include-external-dependencies

# Validate all configurations
terragrunt run-all validate

# Show dependency graph
terragrunt graph-dependencies
```

---

### TFLint

**What it does:** TFLint is a Terraform linter that finds possible errors, warns about deprecated syntax, and enforces best practices.

**Available in:** All images

**Common use cases:**
- Catching errors before terraform plan
- Enforcing naming conventions
- Detecting deprecated syntax
- Validating module usage

**Basic usage:**

```bash
# Initialize TFLint (install plugins)
tflint --init

# Lint current directory
tflint

# Show all available rules
tflint --list-rules
```

**Advanced usage:**

```bash
# Lint with specific config file
tflint --config=.tflint.hcl

# Lint recursively
tflint --recursive

# Output in different formats
tflint --format=json
tflint --format=compact

# Enable specific rule
tflint --enable-rule=terraform_naming_convention
```

---

### Packer

**What it does:** Packer automates the creation of machine images across multiple platforms from a single source configuration.

**Available in:** All images

**Common use cases:**
- Building AMIs for AWS
- Creating GCP images
- Building Docker containers
- Creating multi-platform images from one template

**Basic usage:**

```bash
# Initialize Packer configuration (install plugins)
packer init .

# Validate Packer template
packer validate .

# Build images
packer build .

# Build with variable file
packer build -var-file="variables.pkrvars.hcl" .
```

**Advanced usage:**

```bash
# Build only specific builders
packer build -only=amazon-ebs.ubuntu .

# Enable debug mode
packer build -debug .

# Use variables from command line
packer build -var 'region=us-west-2' -var 'instance_type=t3.micro' .

# Force rebuild
packer build -force .
```

---

## Kubernetes and Container Orchestration

### kubectl

**What it does:** kubectl is the command-line tool for interacting with Kubernetes clusters, allowing you to deploy applications, inspect resources, and manage cluster operations.

**Available in:** All images

**Common use cases:**
- Managing Kubernetes deployments
- Troubleshooting pods and services
- Viewing logs and events
- Applying manifests

**Basic usage:**

```bash
# Get cluster information
kubectl cluster-info

# List all contexts
kubectl config get-contexts

# Switch context
kubectl config use-context my-cluster

# Get pods in all namespaces
kubectl get pods -A

# Get specific resource types
kubectl get deployments
kubectl get services
kubectl get nodes

# Describe resource details
kubectl describe pod <pod-name>

# View logs
kubectl logs <pod-name>
kubectl logs <pod-name> -f  # Follow logs

# Execute command in pod
kubectl exec -it <pod-name> -- /bin/bash
```

**Advanced usage:**

```bash
# Apply configuration from file
kubectl apply -f deployment.yaml

# Apply all manifests in directory
kubectl apply -f ./manifests/

# Delete resources
kubectl delete pod <pod-name>
kubectl delete -f deployment.yaml

# Scale deployments
kubectl scale deployment/nginx --replicas=5

# Port forward to pod
kubectl port-forward pod/<pod-name> 8080:80

# Get resource usage
kubectl top nodes
kubectl top pods

# Label and select resources
kubectl label pods <pod-name> env=production
kubectl get pods -l env=production

# View events
kubectl get events --sort-by='.lastTimestamp'

# Create resources imperatively
kubectl create deployment nginx --image=nginx:latest
kubectl expose deployment nginx --port=80 --type=LoadBalancer
```

---

### Helm

**What it does:** Helm is the package manager for Kubernetes, helping you define, install, and upgrade complex Kubernetes applications using charts.

**Available in:** All images

**Common use cases:**
- Installing third-party applications on Kubernetes
- Managing application releases and rollbacks
- Templating Kubernetes manifests
- Sharing application packages

**Basic usage:**

```bash
# Add a chart repository
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo add stable https://charts.helm.sh/stable

# Update repository index
helm repo update

# Search for charts
helm search repo nginx

# Install a chart
helm install my-release bitnami/nginx

# List installed releases
helm list
helm list -A  # All namespaces

# Upgrade a release
helm upgrade my-release bitnami/nginx

# Uninstall a release
helm uninstall my-release
```

**Advanced usage:**

```bash
# Install with custom values
helm install my-release bitnami/nginx -f custom-values.yaml
helm install my-release bitnami/nginx --set replicaCount=3

# Show chart values
helm show values bitnami/nginx

# Dry-run installation
helm install my-release bitnami/nginx --dry-run --debug

# Rollback to previous release
helm rollback my-release 1

# Get release history
helm history my-release

# Create your own chart
helm create my-chart

# Package a chart
helm package my-chart

# Lint chart
helm lint my-chart
```

---

### k9s

**What it does:** k9s is a terminal-based UI for managing Kubernetes clusters, providing a faster and more intuitive way to observe and interact with your clusters.

**Available in:** All images

**Common use cases:**
- Real-time cluster monitoring
- Quick resource navigation
- Interactive log viewing
- Pod management and troubleshooting

**Basic usage:**

```bash
# Launch k9s
k9s

# Launch in specific namespace
k9s -n kube-system

# Launch with specific context
k9s --context my-cluster
```

**Interactive commands (within k9s):**
- `:pods` - View pods
- `:svc` - View services
- `:deploy` - View deployments
- `:ns` - View namespaces
- `/` - Filter resources
- `l` - View logs
- `d` - Describe resource
- `e` - Edit resource
- `?` - Help

---

## Cloud Provider CLIs

### AWS CLI (`aws-devops` and `all-devops`)

**What it does:** The AWS Command Line Interface is a unified tool to manage AWS services from the command line.

**Available in:** `aws-devops`, `all-devops`

**Common use cases:**
- Managing EC2 instances and security groups
- Working with S3 buckets
- Deploying CloudFormation stacks
- Managing IAM users and roles
- Querying AWS resources

**Basic usage:**

```bash
# Verify authentication
aws sts get-caller-identity

# List S3 buckets
aws s3 ls

# List EC2 instances
aws ec2 describe-instances

# List available regions
aws ec2 describe-regions

# Get account information
aws iam get-user

# Configure profile
aws configure
```

**Advanced usage:**

```bash
# S3 operations
aws s3 cp file.txt s3://my-bucket/
aws s3 sync ./local-folder s3://my-bucket/remote-folder
aws s3 mb s3://my-new-bucket

# EC2 management
aws ec2 run-instances --image-id ami-12345 --instance-type t3.micro
aws ec2 describe-instances --filters "Name=tag:Name,Values=MyInstance"
aws ec2 stop-instances --instance-ids i-1234567890abcdef0

# CloudFormation
aws cloudformation create-stack --stack-name my-stack --template-body file://template.yaml
aws cloudformation describe-stacks --stack-name my-stack
aws cloudformation update-stack --stack-name my-stack --template-body file://template.yaml

# SSM Parameter Store
aws ssm get-parameter --name /my/parameter --with-decryption
aws ssm put-parameter --name /my/parameter --value "secret" --type SecureString

# Query with JMESPath
aws ec2 describe-instances --query 'Reservations[*].Instances[*].[InstanceId,State.Name,Tags[?Key==`Name`].Value|[0]]' --output table

# Use different profiles
aws s3 ls --profile production

# Output formats
aws ec2 describe-instances --output json
aws ec2 describe-instances --output table
aws ec2 describe-instances --output yaml
```

---

### AWS Session Manager Plugin (`aws-devops` and `all-devops`)

**What it does:** The Session Manager plugin enables you to start interactive sessions with EC2 instances without requiring SSH access or bastion hosts.

**Available in:** `aws-devops`, `all-devops`

**Common use cases:**
- Secure shell access to EC2 instances
- Port forwarding to private resources
- Session auditing and logging
- Bastion-less architecture

**Basic usage:**

```bash
# Start interactive session
aws ssm start-session --target i-1234567890abcdef0

# Port forwarding
aws ssm start-session --target i-1234567890abcdef0 \
  --document-name AWS-StartPortForwardingSession \
  --parameters '{"portNumber":["80"],"localPortNumber":["8080"]}'

# Run commands
aws ssm send-command --instance-ids i-1234567890abcdef0 \
  --document-name "AWS-RunShellScript" \
  --parameters 'commands=["uptime"]'
```

---

### Google Cloud CLI (`gcp-devops` and `all-devops`)

**What it does:** The Google Cloud CLI (gcloud) is the primary command-line tool for interacting with Google Cloud Platform services.

**Available in:** `gcp-devops`, `all-devops`

**Common use cases:**
- Managing Compute Engine instances
- Working with Cloud Storage
- Managing GKE clusters
- Deploying Cloud Functions
- Managing IAM policies

**Basic usage:**

```bash
# Authenticate
gcloud auth login

# List authenticated accounts
gcloud auth list

# Set project
gcloud config set project my-project-id

# View current configuration
gcloud config list

# List projects
gcloud projects list

# List compute instances
gcloud compute instances list

# List GKE clusters
gcloud container clusters list
```

**Advanced usage:**

```bash
# Compute Engine operations
gcloud compute instances create my-instance \
  --machine-type=e2-medium \
  --zone=us-central1-a \
  --image-family=debian-11 \
  --image-project=debian-cloud

gcloud compute instances stop my-instance --zone=us-central1-a
gcloud compute ssh my-instance --zone=us-central1-a

# Cloud Storage operations
gcloud storage buckets create gs://my-bucket --location=us-central1
gcloud storage cp file.txt gs://my-bucket/
gcloud storage ls gs://my-bucket/

# GKE cluster management
gcloud container clusters create my-cluster --zone=us-central1-a
gcloud container clusters get-credentials my-cluster --zone=us-central1-a

# IAM management
gcloud projects get-iam-policy my-project-id
gcloud projects add-iam-policy-binding my-project-id \
  --member='user:email@example.com' \
  --role='roles/viewer'

# Cloud Functions
gcloud functions deploy my-function \
  --runtime=python39 \
  --trigger-http \
  --entry-point=main

# Use different configurations
gcloud config configurations create production
gcloud config configurations activate production
```

---

## Configuration Management and Automation

### Ansible

**What it does:** Ansible is an agentless automation tool for configuration management, application deployment, and task automation using simple YAML playbooks.

**Available in:** All images

**Common use cases:**
- Server configuration and provisioning
- Application deployment
- Multi-tier orchestration
- Cloud resource provisioning

**Basic usage:**

```bash
# Check version
ansible --version

# Ping all hosts
ansible all -m ping -i inventory.ini

# Run ad-hoc command
ansible webservers -a "uptime" -i inventory.ini

# Run playbook
ansible-playbook playbook.yml

# Run with inventory file
ansible-playbook -i production.ini playbook.yml

# Check syntax
ansible-playbook --syntax-check playbook.yml

# Dry run
ansible-playbook --check playbook.yml
```

**Advanced usage:**

```bash
# Run with extra variables
ansible-playbook playbook.yml -e "version=1.2.3 env=production"

# Limit to specific hosts
ansible-playbook playbook.yml --limit webserver01

# Use vault for secrets
ansible-playbook playbook.yml --ask-vault-pass
ansible-vault encrypt secrets.yml
ansible-vault decrypt secrets.yml

# Tags
ansible-playbook playbook.yml --tags "configuration,deploy"
ansible-playbook playbook.yml --skip-tags "testing"

# Verbose output
ansible-playbook playbook.yml -v    # verbose
ansible-playbook playbook.yml -vvv  # more verbose
```

---

### ansible-lint

**What it does:** ansible-lint checks Ansible playbooks for best practices, potential errors, and style guidelines.

**Available in:** All images

**Common use cases:**
- Validating playbook syntax
- Enforcing best practices
- Pre-commit checks
- CI/CD quality gates

**Basic usage:**

```bash
# Lint a playbook
ansible-lint playbook.yml

# Lint all YAML files in directory
ansible-lint .

# List all rules
ansible-lint -L

# Exclude specific rules
ansible-lint -x 301,302 playbook.yml
```

---

### pre-commit

**What it does:** pre-commit is a framework for managing and maintaining multi-language pre-commit hooks, ensuring code quality before commits.

**Available in:** All images

**Common use cases:**
- Running linters before commit
- Formatting code automatically
- Preventing bad commits
- Enforcing team standards

**Basic usage:**

```bash
# Install git hook scripts
pre-commit install

# Run all hooks on all files
pre-commit run --all-files

# Run specific hook
pre-commit run terraform-fmt --all-files

# Update hooks to latest versions
pre-commit autoupdate

# Uninstall hooks
pre-commit uninstall
```

---

## Security and Compliance

### Trivy

**What it does:** Trivy is a comprehensive security scanner for containers, filesystems, and IaC configurations, detecting vulnerabilities, misconfigurations, and secrets.

**Available in:** All images

**Common use cases:**
- Scanning container images for vulnerabilities
- Detecting misconfigurations in IaC files
- Finding exposed secrets in code
- CI/CD security gates

**Basic usage:**

```bash
# Scan container image
trivy image nginx:latest
trivy image ghcr.io/jinalshah/devops/images/all-devops:latest

# Scan filesystem
trivy fs /path/to/project

# Scan IaC configurations
trivy config ./terraform/

# Scan for secrets
trivy fs --scanners secret ./
```

**Advanced usage:**

```bash
# Filter by severity
trivy image --severity HIGH,CRITICAL nginx:latest

# Output formats
trivy image --format json nginx:latest
trivy image --format table nginx:latest
trivy image --format sarif nginx:latest

# Ignore unfixed vulnerabilities
trivy image --ignore-unfixed nginx:latest

# Use custom policy
trivy config --policy ./policy ./terraform/

# Generate compliance report
trivy image --compliance docker-cis nginx:latest

# Cache management
trivy image --clear-cache
```

---

## Development and Collaboration

### GitHub CLI (gh)

**What it does:** gh is the official GitHub command-line tool for working with GitHub features like pull requests, issues, and repositories.

**Available in:** All images

**Common use cases:**
- Creating and managing pull requests
- Managing issues
- Repository operations
- GitHub Actions workflows
- Viewing repository information

**Basic usage:**

```bash
# Authenticate
gh auth login

# Check authentication status
gh auth status

# View repository
gh repo view

# Clone repository
gh repo clone owner/repo

# Create repository
gh repo create my-new-repo --public

# List pull requests
gh pr list

# Create pull request
gh pr create --title "Feature" --body "Description"

# View pull request
gh pr view 123

# List issues
gh issue list

# Create issue
gh issue create --title "Bug" --body "Description"
```

**Advanced usage:**

```bash
# Checkout PR locally
gh pr checkout 123

# Review PR
gh pr review 123 --approve
gh pr review 123 --comment --body "Looks good"

# Merge PR
gh pr merge 123 --squash

# GitHub Actions
gh workflow list
gh workflow run image-builder.yml
gh run list
gh run view

# Releases
gh release create v1.0.0 --title "Version 1.0.0" --notes "Release notes"
gh release list

# Gists
gh gist create file.txt
gh gist list
```

---

### ghorg

**What it does:** ghorg is a tool for quickly cloning all repositories from a GitHub organization or user.

**Available in:** All images

**Common use cases:**
- Backing up organization repositories
- Cloning multiple repos for offline work
- Syncing organisation codebases
- Repository migrations

**Basic usage:**

```bash
# Clone all repos from organization
ghorg clone my-org

# Clone all repos from user
ghorg clone my-username --clone-type=user

# Clone with SSH
ghorg clone my-org --protocol=ssh

# Reclone (update existing clones)
ghorg reclone my-org
```

---

### Task (go-task)

**What it does:** Task is a task runner / build tool that aims to be simpler and easier to use than GNU Make, using YAML configuration.

**Available in:** All images

**Common use cases:**
- Project build automation
- Running development tasks
- Multi-step workflows
- Cross-platform task execution

**Basic usage:**

```bash
# List available tasks
task --list
task -l

# Run a task
task build

# Run multiple tasks
task clean build test

# Run with variables
task deploy ENV=production
```

**Example Taskfile.yml:**

```yaml
version: '3'

tasks:
  build:
    desc: Build the application
    cmds:
      - go build -o app main.go

  test:
    desc: Run tests
    cmds:
      - go test ./...

  deploy:
    desc: Deploy application
    cmds:
      - task: build
      - ./deploy.sh {{.ENV}}
```

---

## Programming Languages and Package Managers

### Python 3

**What it does:** Python is a high-level programming language. The images include Python 3.12 with pip for package management.

**Available in:** All images

**Pre-installed packages:**
- `ansible` - Automation framework
- `ansible-lint` - Ansible playbook linter
- `boto3` - AWS SDK (`aws-devops`, `all-devops`)
- `cfn-lint` - CloudFormation linter (`aws-devops`, `all-devops`)
- `jmespath` - JSON query language
- `mkdocs-material` - Documentation generator
- `paramiko` - SSH library
- `pre-commit` - Git hook framework
- `pytest` - Testing framework (`aws-devops`, `all-devops`)
- `requests` - HTTP library (`aws-devops`, `all-devops`)
- `s3cmd` - S3 tool (`aws-devops`, `all-devops`)

**Basic usage:**

```bash
# Check Python version
python3 --version

# Run Python script
python3 script.py

# Install package
pip install package-name

# Install from requirements
pip install -r requirements.txt

# List installed packages
pip list

# Create virtual environment
python3 -m venv myenv
source myenv/bin/activate
```

---

### Node.js and npm

**What it does:** Node.js is a JavaScript runtime built on Chrome's V8 engine. npm is the package manager for Node.js.

**Available in:** All images (LTS version)

**Common use cases:**
- Running JavaScript applications
- Building web applications
- Installing development tools
- Package management

**Basic usage:**

```bash
# Check versions
node --version
npm --version
npx --version

# Run JavaScript file
node app.js

# Initialize new project
npm init
npm init -y  # Skip prompts

# Install packages
npm install express
npm install -g @angular/cli  # Global installation

# Install from package.json
npm install

# Run scripts
npm start
npm test
npm run build
```

---

## AI and Code Assistant CLIs

### Claude CLI

**What it does:** Official CLI for Anthropic's Claude AI assistant for code generation, analysis, and automation.

**Available in:** All images

**Common use cases:**
- Code generation and refactoring
- Documentation generation
- Code review assistance
- Automated problem solving

**Basic usage:**

```bash
# Check version (requires authentication for full functionality)
claude --version

# Authenticate
claude auth login

# Ask questions
claude "Explain this function" --file main.py

# Generate code
claude "Create a Python function to parse JSON"
```

**Note:** Requires authentication via `~/.claude` configuration. Mount this directory when running the container.

---

### OpenAI Codex CLI

**What it does:** CLI tool for OpenAI's Codex model for code generation and completion.

**Available in:** All images

**Basic usage:**

```bash
# Check installation
codex --version

# Note: Requires OpenAI API key and authentication
```

**Note:** Requires authentication configuration. Mount `~/.codex` when running the container.

---

### GitHub Copilot CLI

**What it does:** Command-line interface for GitHub Copilot to get code suggestions directly in the terminal.

**Available in:** All images

**Basic usage:**

```bash
# Check installation
copilot --version

# Note: Requires GitHub Copilot subscription and authentication
```

**Note:** Requires GitHub authentication. Mount `~/.copilot` when running the container.

---

### Google Gemini CLI

**What it does:** CLI interface for Google's Gemini AI model for code assistance and generation.

**Available in:** All images

**Basic usage:**

```bash
# Check installation
gemini --version

# Note: Requires Google Cloud authentication and API access
```

**Note:** Requires Google Cloud credentials. Mount `~/.gemini` when running the container.

---

## Database Clients

### MongoDB Shell (mongosh)

**What it does:** mongosh is the modern MongoDB shell for connecting to and interacting with MongoDB databases.

**Available in:** All images (MongoDB 6.0 compatible)

**Common use cases:**
- Connecting to MongoDB instances
- Running database queries
- Database administration
- Data import/export

**Basic usage:**

```bash
# Connect to local MongoDB
mongosh

# Connect to remote MongoDB
mongosh "mongodb://username:password@hostname:27017/database"

# Connect with connection string
mongosh "mongodb+srv://cluster.mongodb.net/myDatabase"

# Run command
mongosh --eval "db.adminCommand('listDatabases')"
```

**Interactive commands:**

```javascript
// Show databases
show dbs

// Use database
use mydb

// Show collections
show collections

// Query documents
db.mycollection.find()
db.mycollection.findOne({ name: "John" })

// Insert document
db.mycollection.insertOne({ name: "Jane", age: 30 })

// Update document
db.mycollection.updateOne({ name: "Jane" }, { $set: { age: 31 } })

// Delete document
db.mycollection.deleteOne({ name: "Jane" })
```

---

### PostgreSQL Client (psql)

**What it does:** psql is the interactive terminal client for PostgreSQL databases.

**Available in:** All images (PostgreSQL 17)

**Common use cases:**
- Connecting to PostgreSQL databases
- Running SQL queries
- Database administration
- Schema management

**Basic usage:**

```bash
# Connect to local PostgreSQL
psql -U username -d database

# Connect to remote PostgreSQL
psql -h hostname -U username -d database -p 5432

# Run SQL file
psql -U username -d database -f script.sql

# Run single command
psql -U username -d database -c "SELECT version();"

# Export query results
psql -U username -d database -c "SELECT * FROM users;" -o output.txt
```

**Interactive commands:**

```sql
-- List databases
\l

-- Connect to database
\c database_name

-- List tables
\dt

-- Describe table
\d table_name

-- List schemas
\dn

-- Execute SQL file
\i script.sql

-- Quit
\q
```

---

### MySQL Client

**What it does:** mysql is the command-line client for MySQL and MariaDB databases.

**Available in:** All images

**Common use cases:**
- Connecting to MySQL/MariaDB databases
- Running SQL queries
- Database imports and exports
- Schema management

**Basic usage:**

```bash
# Connect to MySQL
mysql -u username -p -h hostname database

# Execute SQL file
mysql -u username -p database < script.sql

# Execute command
mysql -u username -p -e "SHOW DATABASES;"

# Dump database
mysqldump -u username -p database > backup.sql
```

---

## Network and Diagnostic Tools

### dig (DNS lookup)

**What it does:** dig is a flexible DNS lookup utility for querying DNS name servers.

**Available in:** All images (part of bind-utils)

**Common use cases:**
- DNS troubleshooting
- Checking DNS records
- Verifying DNS propagation
- Diagnosing DNS issues

**Basic usage:**

```bash
# Basic lookup
dig google.com

# Query specific record type
dig google.com A
dig google.com MX
dig google.com TXT
dig google.com NS

# Query specific nameserver
dig @8.8.8.8 google.com

# Reverse DNS lookup
dig -x 8.8.8.8

# Short output
dig google.com +short

# Trace DNS path
dig google.com +trace
```

---

### nslookup

**What it does:** nslookup is a network administration tool for querying Domain Name System records.

**Available in:** All images (part of bind-utils)

**Basic usage:**

```bash
# Basic lookup
nslookup google.com

# Query specific nameserver
nslookup google.com 8.8.8.8

# Interactive mode
nslookup
> server 8.8.8.8
> set type=MX
> google.com
> exit
```

---

### ncat (Netcat)

**What it does:** ncat is a networking utility for reading, writing, and redirecting data across network connections.

**Available in:** All images (part of nmap-ncat)

**Common use cases:**
- Port scanning
- Network debugging
- Banner grabbing
- Simple TCP/UDP connections

**Basic usage:**

```bash
# Check version
ncat --version

# Connect to host and port
ncat google.com 80

# Listen on port
ncat -l 8080

# Port scan
ncat -zv hostname 20-100

# Simple chat
# Server: ncat -l 9999
# Client: ncat hostname 9999

# Transfer file
# Server: ncat -l 9999 > received_file
# Client: ncat hostname 9999 < file_to_send
```

---

### telnet

**What it does:** telnet is a network protocol tool for bidirectional interactive text-oriented communication.

**Available in:** All images

**Common use cases:**
- Testing TCP connections
- Checking port availability
- Debugging network services
- Simple protocol testing

**Basic usage:**

```bash
# Connect to host and port
telnet hostname 80

# Test SMTP
telnet mail.example.com 25

# Test HTTP
telnet google.com 80
GET / HTTP/1.1
Host: google.com
```

---

### curl and wget

**What it does:** curl and wget are command-line tools for transferring data with URLs, supporting various protocols.

**Available in:** All images

**Basic usage:**

```bash
# curl examples
curl https://api.example.com
curl -o file.txt https://example.com/file.txt
curl -X POST -H "Content-Type: application/json" -d '{"key":"value"}' https://api.example.com

# wget examples
wget https://example.com/file.txt
wget -r https://example.com  # Recursive download
wget -c https://example.com/large-file.zip  # Resume download
```

---

## Shell and Terminal Tools

### Zsh (Default Shell)

**What it does:** Zsh is an extended Unix shell with advanced features and customisation.

**Available in:** All images (default shell)

**Features:**
- Oh My Zsh framework pre-installed
- Theme: candy
- Command completion
- Command history
- Directory navigation enhancements

**Basic usage:**

```bash
# Start zsh (default shell)
zsh

# Oh My Zsh configuration file
~/.zshrc
```

---

### Bash

**What it does:** Bash is the GNU Bourne-Again Shell, a widely-used Unix shell.

**Available in:** All images

**Basic usage:**

```bash
# Start bash
bash

# Configuration file
~/.bashrc
```

---

### Fish

**What it does:** Fish is a smart and user-friendly command-line shell with autosuggestions and syntax highlighting.

**Available in:** All images

**Basic usage:**

```bash
# Start fish
fish

# Interactive configuration
fish_config
```

---

## Compression and Archive Tools

### zip/unzip

**What it does:** Tools for creating and extracting ZIP archives.

**Available in:** All images

**Basic usage:**

```bash
# Create zip archive
zip archive.zip file1 file2
zip -r archive.zip directory/

# Extract zip archive
unzip archive.zip
unzip archive.zip -d /destination/

# List contents
unzip -l archive.zip
```

---

### tar, gzip, bzip2

**What it does:** Tools for archiving and compression.

**Available in:** All images

**Basic usage:**

```bash
# Create tar.gz archive
tar -czf archive.tar.gz directory/

# Extract tar.gz archive
tar -xzf archive.tar.gz

# Create tar.bz2 archive
tar -cjf archive.tar.bz2 directory/

# Extract tar.bz2 archive
tar -xjf archive.tar.bz2

# List contents
tar -tzf archive.tar.gz
```

---

## Additional Utilities

### jq (JSON processor)

**What it does:** jq is a lightweight command-line JSON processor for parsing, filtering, and transforming JSON data.

**Available in:** All images

**Common use cases:**
- Parsing API responses
- Filtering JSON data
- Transforming JSON structures
- Pretty-printing JSON

**Basic usage:**

```bash
# Pretty-print JSON
echo '{"name":"John","age":30}' | jq .

# Extract specific field
echo '{"name":"John","age":30}' | jq '.name'

# Filter array
echo '[{"name":"John","age":30},{"name":"Jane","age":25}]' | jq '.[] | select(.age > 26)'

# Transform data
echo '{"first":"John","last":"Doe"}' | jq '{fullName: "\(.first) \(.last)"}'

# Read from file
jq '.users[] | .name' data.json
```

---

### Git

**What it does:** Git is a distributed version control system for tracking changes in source code.

**Available in:** All images

**Basic usage:**

```bash
# Clone repository
git clone https://github.com/user/repo.git

# Basic workflow
git add .
git commit -m "Commit message"
git push

# Branch operations
git branch feature-branch
git checkout feature-branch
git merge main

# View status and history
git status
git log
git diff
```

---

### vim and less

**What it does:** Text editors and pagers for viewing and editing files.

**Available in:** All images

**Basic vim usage:**

```bash
# Open file
vim filename

# Basic commands (in vim)
# i - Insert mode
# Esc - Normal mode
# :w - Save
# :q - Quit
# :wq - Save and quit
```

---

### tree

**What it does:** tree displays directory structures in a tree-like format.

**Available in:** All images

**Basic usage:**

```bash
# Display directory tree
tree

# Limit depth
tree -L 2

# Show hidden files
tree -a

# Show only directories
tree -d
```

---

## Authentication Note for AI CLIs

All AI CLI tools (`claude`, `codex`, `copilot`, `gemini`) require authentication before use. When running containers with these tools:

```bash
docker run -it --rm \
  -v ~/.claude:/root/.claude \
  -v ~/.codex:/root/.codex \
  -v ~/.copilot:/root/.copilot \
  -v ~/.gemini:/root/.gemini \
  ghcr.io/jinalshah/devops/images/all-devops:latest
```

Refer to each tool's official documentation for authentication setup.
