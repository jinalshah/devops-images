# Jenkins CI/CD Integration

Complete guide to using DevOps Images in Jenkins pipelines for automated infrastructure deployment, testing, and validation.

!!! tip "Why Jenkins?"
    - Self-hosted control and customization
    - Extensive plugin ecosystem
    - Docker pipeline support
    - Works with any container registry

---

## Basic Setup

### Prerequisites

Ensure Jenkins has Docker pipeline plugin installed:

- **Docker Pipeline Plugin**
- **Docker Plugin**
- **Kubernetes Plugin** (optional, for Kubernetes agents)

---

## Declarative Pipeline

### Simple Terraform Deployment

```groovy
pipeline {
    agent {
        docker {
            image 'ghcr.io/jinalshah/devops/images/all-devops:1.0.abc1234'  // (1)!
            args '-v $HOME/.aws:/root/.aws'  // (2)!
        }
    }

    environment {  // (3)!
        AWS_REGION = 'us-east-1'
    }

    stages {
        stage('Terraform Init') {
            steps {
                sh 'terraform init'
            }
        }

        stage('Terraform Plan') {
            steps {
                sh 'terraform plan -out=tfplan'
            }
        }

        stage('Terraform Apply') {
            when {
                branch 'main'  // (4)!
            }
            steps {
                input message: 'Deploy to production?', ok: 'Deploy'  // (5)!
                sh 'terraform apply tfplan'
            }
        }
    }

    post {  // (6)!
        always {
            cleanWs()
        }
        success {
            echo 'Deployment successful!'
        }
        failure {
            echo 'Deployment failed!'
        }
    }
}
```

1. Use DevOps Image as agent container
2. Mount AWS credentials from Jenkins host
3. Define environment variables
4. Only deploy from main branch
5. Manual approval gate
6. Post-build actions

---

## Multi-Stage Pipeline

### Validate → Plan → Apply

```groovy
pipeline {
    agent {
        docker {
            image 'ghcr.io/jinalshah/devops/images/all-devops:1.0.abc1234'
        }
    }

    parameters {  // (1)!
        choice(
            name: 'ENVIRONMENT',
            choices: ['dev', 'staging', 'production'],
            description: 'Target environment'
        )
        booleanParam(
            name: 'AUTO_APPROVE',
            defaultValue: false,
            description: 'Auto-approve Terraform apply'
        )
    }

    environment {
        TF_DIR = "${WORKSPACE}/terraform/${params.ENVIRONMENT}"
        AWS_CREDENTIALS = credentials('aws-credentials')  // (2)!
    }

    stages {
        stage('Validate') {
            parallel {  // (3)!
                stage('Terraform Format') {
                    steps {
                        dir("${TF_DIR}") {
                            sh 'terraform fmt -check -recursive'
                        }
                    }
                }
                stage('TFLint') {
                    steps {
                        dir("${TF_DIR}") {
                            sh 'tflint --init'
                            sh 'tflint'
                        }
                    }
                }
                stage('Trivy Scan') {
                    steps {
                        sh 'trivy config ${TF_DIR} --severity HIGH,CRITICAL'
                    }
                }
            }
        }

        stage('Terraform Plan') {
            steps {
                dir("${TF_DIR}") {
                    sh 'terraform init'
                    sh 'terraform plan -out=tfplan'
                }
            }
        }

        stage('Approval') {
            when {
                expression { !params.AUTO_APPROVE }
            }
            steps {
                input message: "Deploy to ${params.ENVIRONMENT}?", ok: 'Deploy'
            }
        }

        stage('Terraform Apply') {
            steps {
                dir("${TF_DIR}") {
                    sh 'terraform apply tfplan'
                }
            }
        }
    }

    post {
        always {
            archiveArtifacts artifacts: '**/tfplan', allowEmptyArchive: true
            cleanWs()
        }
        success {
            emailext (
                subject: "SUCCESS: Terraform deployment to ${params.ENVIRONMENT}",
                body: "Terraform deployment completed successfully.",
                to: '$DEFAULT_RECIPIENTS'
            )
        }
        failure {
            emailext (
                subject: "FAILED: Terraform deployment to ${params.ENVIRONMENT}",
                body: "Terraform deployment failed. Check console output.",
                to: '$DEFAULT_RECIPIENTS'
            )
        }
    }
}
```

1. Pipeline parameters for user input
2. Jenkins credentials binding
3. Run validation stages in parallel

---

## Scripted Pipeline

### Advanced Multi-Cloud Deployment

```groovy
node {
    def dockerImage = 'ghcr.io/jinalshah/devops/images/all-devops:1.0.abc1234'

    stage('Checkout') {
        checkout scm
    }

    docker.image(dockerImage).inside('-v $HOME/.aws:/root/.aws -v $HOME/.config/gcloud:/root/.config/gcloud') {
        try {
            stage('AWS Deployment') {
                withCredentials([
                    string(credentialsId: 'aws-access-key', variable: 'AWS_ACCESS_KEY_ID'),
                    string(credentialsId: 'aws-secret-key', variable: 'AWS_SECRET_ACCESS_KEY')
                ]) {
                    dir('terraform/aws') {
                        sh 'terraform init'
                        sh 'terraform plan -out=aws-tfplan'
                        sh 'terraform apply aws-tfplan'
                    }
                }
            }

            stage('GCP Deployment') {
                withCredentials([file(credentialsId: 'gcp-sa-key', variable: 'GCP_KEY_FILE')]) {
                    sh 'export GOOGLE_APPLICATION_CREDENTIALS=${GCP_KEY_FILE}'
                    dir('terraform/gcp') {
                        sh 'terraform init'
                        sh 'terraform plan -out=gcp-tfplan'
                        sh 'terraform apply gcp-tfplan'
                    }
                }
            }

        } catch (Exception e) {
            currentBuild.result = 'FAILURE'
            throw e
        } finally {
            cleanWs()
        }
    }
}
```

---

## Shared Library Integration

### Reusable Pipeline Functions

**`vars/terraformDeploy.groovy`**:

```groovy
def call(Map config) {
    pipeline {
        agent {
            docker {
                image config.image ?: 'ghcr.io/jinalshah/devops/images/all-devops:1.0.abc1234'
            }
        }

        stages {
            stage('Terraform Deploy') {
                steps {
                    script {
                        withCredentials([
                            string(credentialsId: config.awsKeyId, variable: 'AWS_ACCESS_KEY_ID'),
                            string(credentialsId: config.awsSecretKey, variable: 'AWS_SECRET_ACCESS_KEY')
                        ]) {
                            dir(config.terraformDir) {
                                sh 'terraform init'
                                sh "terraform plan -out=tfplan"
                                if (config.autoApprove) {
                                    sh 'terraform apply tfplan'
                                } else {
                                    input message: 'Deploy?', ok: 'Deploy'
                                    sh 'terraform apply tfplan'
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
```

**Using the shared library**:

```groovy
@Library('devops-pipeline') _

terraformDeploy(
    terraformDir: 'terraform/production',
    awsKeyId: 'aws-access-key',
    awsSecretKey: 'aws-secret-key',
    autoApprove: false
)
```

---

## Kubernetes Deployment

### Deploy to EKS/GKE with Helm

```groovy
pipeline {
    agent {
        docker {
            image 'ghcr.io/jinalshah/devops/images/all-devops:1.0.abc1234'
            args '-v $HOME/.kube:/root/.kube'
        }
    }

    environment {
        AWS_REGION = 'us-east-1'
        CLUSTER_NAME = 'my-eks-cluster'
        NAMESPACE = 'production'
    }

    stages {
        stage('Configure kubectl') {
            steps {
                withAWS(credentials: 'aws-credentials', region: env.AWS_REGION) {
                    sh """
                        aws eks update-kubeconfig \
                            --region ${AWS_REGION} \
                            --name ${CLUSTER_NAME}
                    """
                }
            }
        }

        stage('Deploy with Helm') {
            steps {
                sh """
                    helm upgrade --install myapp ./charts/myapp \
                        --namespace ${NAMESPACE} \
                        --create-namespace \
                        --set image.tag=${env.BUILD_NUMBER} \
                        --wait \
                        --timeout 5m
                """
            }
        }

        stage('Verify Deployment') {
            steps {
                sh "kubectl rollout status deployment/myapp -n ${NAMESPACE}"
                sh "kubectl get pods -n ${NAMESPACE}"
            }
        }
    }
}
```

---

## Security Scanning Pipeline

### Comprehensive Security Checks

```groovy
pipeline {
    agent {
        docker {
            image 'ghcr.io/jinalshah/devops/images/all-devops:1.0.abc1234'
        }
    }

    stages {
        stage('Security Scans') {
            parallel {
                stage('Trivy IaC Scan') {
                    steps {
                        sh '''
                            trivy config ./terraform \
                                --format json \
                                --output trivy-report.json
                            trivy config ./terraform \
                                --severity HIGH,CRITICAL \
                                --exit-code 1
                        '''
                    }
                }

                stage('TFLint') {
                    steps {
                        dir('terraform') {
                            sh 'tflint --init'
                            sh 'tflint --minimum-failure-severity=error'
                        }
                    }
                }

                stage('CloudFormation Lint') {
                    when {
                        expression {
                            fileExists('cloudformation')
                        }
                    }
                    steps {
                        sh 'cfn-lint cloudformation/**/*.yaml'
                    }
                }

                stage('Ansible Lint') {
                    when {
                        expression {
                            fileExists('ansible')
                        }
                    }
                    steps {
                        sh 'ansible-lint ansible/'
                    }
                }
            }
        }
    }

    post {
        always {
            publishHTML([
                reportDir: '.',
                reportFiles: 'trivy-report.json',
                reportName: 'Trivy Security Report'
            ])
        }
    }
}
```

---

## Multi-Branch Pipeline

### Automatic Branch Detection

**Jenkinsfile**:

```groovy
pipeline {
    agent {
        docker {
            image 'ghcr.io/jinalshah/devops/images/all-devops:1.0.abc1234'
        }
    }

    stages {
        stage('Determine Environment') {
            steps {
                script {
                    if (env.BRANCH_NAME == 'main') {
                        env.DEPLOY_ENV = 'production'
                    } else if (env.BRANCH_NAME == 'staging') {
                        env.DEPLOY_ENV = 'staging'
                    } else {
                        env.DEPLOY_ENV = 'dev'
                    }
                    echo "Deploying to: ${env.DEPLOY_ENV}"
                }
            }
        }

        stage('Deploy') {
            steps {
                dir("terraform/${env.DEPLOY_ENV}") {
                    sh 'terraform init'
                    sh 'terraform apply -auto-approve'
                }
            }
        }
    }
}
```

**Jenkins Configuration**:

1. Create a Multibranch Pipeline job
2. Configure branch sources (Git)
3. Set scan triggers
4. Jenkins automatically creates jobs for each branch

---

## AI-Assisted Code Review

### Automated Review with Claude CLI

```groovy
pipeline {
    agent {
        docker {
            image 'ghcr.io/jinalshah/devops/images/all-devops:1.0.abc1234'
        }
    }

    environment {
        CLAUDE_API_KEY = credentials('claude-api-key')
    }

    stages {
        stage('AI Code Review') {
            when {
                changeRequest()  // Only on pull requests
            }
            steps {
                script {
                    // Get changed files
                    sh 'git diff origin/main...HEAD -- terraform/ > changes.diff'

                    // Setup Claude CLI
                    sh '''
                        mkdir -p ~/.claude
                        echo "${CLAUDE_API_KEY}" > ~/.claude/config.json
                    '''

                    // Review with Claude
                    sh '''
                        claude "Review this Terraform code for security issues and best practices" \
                            --file changes.diff \
                            > review-output.md
                    '''

                    // Archive review
                    archiveArtifacts artifacts: 'review-output.md'

                    // Post as comment (if using GitHub)
                    sh '''
                        curl -X POST \
                            -H "Authorization: token ${GITHUB_TOKEN}" \
                            -d "{\\"body\\": \\"$(cat review-output.md)\\"}" \
                            https://api.github.com/repos/owner/repo/issues/${CHANGE_ID}/comments
                    '''
                }
            }
        }
    }
}
```

---

## Best Practices

!!! tip "Performance Optimization"

    1. **Reuse Docker agents**: Use `reuseNode true` to avoid creating new containers
    2. **Cache Docker images**: Configure Docker to cache pulled images
    3. **Use shared libraries**: Avoid duplicating pipeline code
    4. **Parallel stages**: Run independent stages in parallel
    5. **Workspace cleanup**: Use `cleanWs()` to free disk space

!!! tip "Security Best Practices"

    1. **Use Jenkins Credentials**: Store secrets in Jenkins credential store
    2. **Limit credential scope**: Use folder-level credentials when possible
    3. **Audit credential usage**: Review credential access logs regularly
    4. **Use approval gates**: Add `input` steps for production deployments
    5. **Mask sensitive output**: Use `wrap([$class: 'MaskPasswordsBuildWrapper'])`

!!! warning "Common Pitfalls"

    - ❌ **Hardcoding credentials**: Always use Jenkins credentials
    - ❌ **No workspace cleanup**: Can fill up disk space
    - ❌ **Using `latest` tag**: Non-reproducible builds
    - ❌ **No error handling**: Use try/catch in scripted pipelines

---

## Credentials Management

### Storing Credentials

**Via Jenkins UI**:

1. Navigate to: `Manage Jenkins → Manage Credentials`
2. Add credential:
   - **Secret text**: For API keys, tokens
   - **Secret file**: For service account keys
   - **Username with password**: For cloud credentials

**Using credentials in pipeline**:

```groovy
withCredentials([
    string(credentialsId: 'aws-access-key', variable: 'AWS_ACCESS_KEY_ID'),
    string(credentialsId: 'aws-secret-key', variable: 'AWS_SECRET_ACCESS_KEY')
]) {
    sh 'terraform apply'
}
```

---

## Troubleshooting

??? question "Docker agent fails to start"

    **Problem**: Jenkins can't start Docker agent

    **Solutions**:
    1. Verify Jenkins has Docker permissions:
       ```bash
       sudo usermod -aG docker jenkins
       sudo systemctl restart jenkins
       ```
    2. Check Docker daemon is running:
       ```bash
       sudo systemctl status docker
       ```

??? question "Credentials not available in container"

    **Problem**: Environment variables not accessible inside Docker container

    **Solution**: Use `withCredentials` block inside Docker agent:
    ```groovy
    docker.image('...').inside() {
        withCredentials([...]) {
            sh 'terraform apply'
        }
    }
    ```

??? question "Workspace permissions issues"

    **Problem**: Permission denied errors in workspace

    **Solution**: Run container with correct user:
    ```groovy
    agent {
        docker {
            image '...'
            args '-u root'  // Run as root if needed
        }
    }
    ```

---

## Example Repository Structure

```
.
├── Jenkinsfile                    # Main pipeline
├── Jenkinsfile.security           # Security scan pipeline
├── vars/
│   ├── terraformDeploy.groovy     # Shared library
│   └── helmDeploy.groovy          # Shared library
├── terraform/
│   ├── dev/
│   ├── staging/
│   └── production/
├── ansible/
│   └── playbooks/
└── charts/
    └── myapp/
```

---

## Next Steps

- [GitHub Actions Integration](ci-cd-github.md) - GitHub Actions examples
- [GitLab CI Integration](ci-cd-gitlab.md) - GitLab CI examples
- [CircleCI Integration](ci-cd-circleci.md) - CircleCI config examples
- [AI-Assisted DevOps](ai-assisted-devops.md) - AI workflow automation
- [Multi-Tool Patterns](multi-tool-patterns.md) - Combining multiple tools
