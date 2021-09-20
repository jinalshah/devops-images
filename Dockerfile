ARG GCLOUD_VERSION=345.0.0
ARG PACKER_VERSION=1.7.3
ARG TERRAGRUNT_VERSION=0.30.4
ARG TFLINT_VERSION=0.29.1
ARG TFSEC_VERSION=0.40.4
ARG PYTHON_VERSION=3.8.12
ARG PYTHON_VERSION_TO_USE=python3.8

FROM centos:latest AS base

LABEL name=devops

ARG GCLOUD_VERSION
ARG PACKER_VERSION
ARG TERRAGRUNT_VERSION
ARG TFLINT_VERSION
ARG TFSEC_VERSION
ARG PYTHON_VERSION
ARG PYTHON_VERSION_TO_USE


ENV CLOUDSDK_PYTHON=python3
ENV PATH /usr/lib/google-cloud-sdk/bin:$PATH

# Customisations
COPY scripts/*.sh /tmp/
RUN \
  # useradd devops && \
  # \
  # . /tmp/20-bashrc.sh && \
  # \
  chmod +x /tmp/30-clone-all-repos.sh && \
  mv /tmp/30-clone-all-repos.sh /usr/local/bin/clone-all-repos && \
  \
  # Install Packages via Yum
  yum install -y \
    glibc-langpack-en \
    epel-release \
    && \
  \
  yum install -y \
    # ansible \
    bash \
    bash-completion \
    curl \
    git \
    jq \
    less \
    make \
    openssh-clients \
    python3 \
    tree \
    vim \
    wget \
    unzip \
    zip \
    && \
  \
  # Install binaries to compile Python 3.8
  yum install -y \
    gcc \
    openssl-devel \
    bzip2-devel \
    libffi-devel \
    zlib-devel \
    && \
  \
  # Install Python 3.8
  cd /tmp && \
  wget -q https://www.python.org/ftp/python/${PYTHON_VERSION}/Python-${PYTHON_VERSION}.tgz && \
  tar -zxvf Python-${PYTHON_VERSION}.tgz && \
  cd Python-${PYTHON_VERSION} && \
  ./configure --enable-optimizations && \
  make altinstall && \
  cd /tmp && \
  rm -rf Python* && \
  \
  python3 -m pip install --upgrade -U pip  && \
  ${PYTHON_VERSION_TO_USE} -m pip install --upgrade -U pip  && \
  \
  ${PYTHON_VERSION_TO_USE} -m pip install --upgrade ansible && \
  ${PYTHON_VERSION_TO_USE} -m pip install --upgrade ansible-lint[yamllint] && \
  ${PYTHON_VERSION_TO_USE} -m pip install --upgrade mkdocs-material && \
  ${PYTHON_VERSION_TO_USE} -m pip install --upgrade paramiko && \
  \
  # Ansible Configuration
  mkdir -p /etc/ansible/roles && \
  wget -q -O /etc/ansible/ansible.cfg https://raw.githubusercontent.com/ansible/ansible/devel/examples/ansible.cfg && \
  wget -q -O /etc/ansible/hosts https://raw.githubusercontent.com/ansible/ansible/devel/examples/hosts && \
  \
  # Cleanup \
  yum clean packages && \
  yum clean metadata && \
  yum clean all && \
  rm -rf /tmp/* && \
  rm -rf /var/tmp/* && \
  rm -rf ~/.wget-hsts

RUN \
  # Kubectl Configuration
  wget -q -O /tmp/kubectl https://storage.googleapis.com/kubernetes-release/release/`curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt`/bin/linux/amd64/kubectl && \
  chmod +x /tmp/kubectl && \
  mv /tmp/kubectl /usr/local/bin && \
  \
  # Install tfswitch and Install latest version of Terraform
  curl -L https://raw.githubusercontent.com/warrensbox/terraform-switcher/release/install.sh | bash && \
  tfswitch --latest && \
  \
  wget -qO /tmp/terragrunt https://github.com/gruntwork-io/terragrunt/releases/download/v${TERRAGRUNT_VERSION}/terragrunt_linux_amd64 && \
  chmod +x /tmp/terragrunt && \
  mv /tmp/terragrunt /usr/local/bin && \
  \
  wget -qO /tmp/tflint.zip https://github.com/terraform-linters/tflint/releases/download/v${TFLINT_VERSION}/tflint_linux_amd64.zip && \
  unzip -q /tmp/tflint.zip -d /tmp && \
  chmod +x /tmp/tflint && \
  mv /tmp/tflint /usr/local/bin && \
  \
  wget -qO /tmp/tfsec https://github.com/liamg/tfsec/releases/download/v${TFSEC_VERSION}/tfsec-linux-amd64 && \
  chmod +x /tmp/tfsec && \
  mv /tmp/tfsec /usr/local/bin && \
  \
  wget -qO /tmp/packer.zip https://releases.hashicorp.com/packer/${PACKER_VERSION}/packer_${PACKER_VERSION}_linux_amd64.zip && \
  unzip -q /tmp/packer.zip -d /tmp && \
  chmod +x /tmp/packer && \
  mv /tmp/packer /usr/local/bin && \
  \
  # Cleanup
  rm -rf /tmp/* && \
  rm -rf /var/tmp/* && \
  rm ~/.wget-hsts && \
  \
  # Confirm Version
  ansible --version && \
  echo $SHELL && \
  kubectl version --client && \
  python3 --version && \
  python3.8 --version && \
  terraform version && \
  terragrunt -version && \
  tflint --version && \
  tfsec --version && \
  packer version

FROM base AS all-devops

ARG GCLOUD_VERSION
ARG PACKER_VERSION
ARG TERRAGRUNT_VERSION
ARG TFLINT_VERSION
ARG TFSEC_VERSION
ARG PYTHON_VERSION
ARG PYTHON_VERSION_TO_USE

RUN \
  # AWS Python Requirements
  ${PYTHON_VERSION_TO_USE} -m pip install --upgrade --no-cache-dir -U crcmod && \
  ${PYTHON_VERSION_TO_USE} -m pip install --upgrade pytest && \
  ${PYTHON_VERSION_TO_USE} -m pip install --upgrade s3cmd && \
  ${PYTHON_VERSION_TO_USE} -m pip install --upgrade boto3 && \
  ${PYTHON_VERSION_TO_USE} -m pip install --upgrade requests && \
  ${PYTHON_VERSION_TO_USE} -m pip install --upgrade bs4 && \
  ${PYTHON_VERSION_TO_USE} -m pip install --upgrade lxml && \
  \
  # AWS Configuration
  cd /tmp && \
  curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" && \
  unzip awscliv2.zip && \
  /tmp/aws/install && \
  \
  # AWS Session Manager Plugin Installation
  cd /tmp && \
  curl "https://s3.amazonaws.com/session-manager-downloads/plugin/latest/linux_64bit/session-manager-plugin.rpm" -o "session-manager-plugin.rpm" && \
  yum install -y session-manager-plugin.rpm && \
  \
  # GCP / gcloud Configuration
  wget -q -O /tmp/google-cloud-sdk.tar.gz https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-sdk-${GCLOUD_VERSION}-linux-x86_64.tar.gz && \
  tar -zxvf /tmp/google-cloud-sdk.tar.gz -C /usr/lib/ && \
  /usr/lib/google-cloud-sdk/install.sh --rc-path=/root/.bashrc --command-completion=true --path-update=true --quiet && \
  source ~/.bashrc && \
  gcloud components install beta docker-credential-gcr --quiet && \
#  gcloud config set core/disable_usage_reporting true && \
#  gcloud config set component_manager/disable_update_check true && \
#  gcloud config set metrics/environment github_docker_image && \
  rm -rf /tmp/google-cloud-sdk.tar.gz && \
  \
  # Cleanup
  rm -rf /tmp/* && \
  rm -rf /var/tmp/* && \
  rm ~/.wget-hsts && \
  # Confirm Version
  aws --version && \
  gcloud --version

FROM base AS aws-devops

ARG GCLOUD_VERSION
ARG PACKER_VERSION
ARG TERRAGRUNT_VERSION
ARG TFLINT_VERSION
ARG TFSEC_VERSION
ARG PYTHON_VERSION
ARG PYTHON_VERSION_TO_USE

RUN \
  # AWS Python Requirements
  ${PYTHON_VERSION_TO_USE} -m pip install --upgrade --no-cache-dir -U crcmod && \
  ${PYTHON_VERSION_TO_USE} -m pip install --upgrade pytest && \
  ${PYTHON_VERSION_TO_USE} -m pip install --upgrade s3cmd && \
  ${PYTHON_VERSION_TO_USE} -m pip install --upgrade boto3 && \
  ${PYTHON_VERSION_TO_USE} -m pip install --upgrade requests && \
  ${PYTHON_VERSION_TO_USE} -m pip install --upgrade bs4 && \
  ${PYTHON_VERSION_TO_USE} -m pip install --upgrade lxml && \
  \
  # AWS Configuration
  cd /tmp && \
  curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" && \
  unzip awscliv2.zip && \
  /tmp/aws/install && \
  \
  # AWS Session Manager Plugin Installation
  cd /tmp && \
  curl "https://s3.amazonaws.com/session-manager-downloads/plugin/latest/linux_64bit/session-manager-plugin.rpm" -o "session-manager-plugin.rpm" && \
  yum install -y session-manager-plugin.rpm && \
  \
  # Cleanup
  rm -rf /tmp/* && \
  rm -rf /var/tmp/* && \
  rm -rf ~/.wget-hsts && \
  # Confirm Version
  aws --version

FROM base AS gcp-devops

ARG GCLOUD_VERSION
ARG PACKER_VERSION
ARG TERRAGRUNT_VERSION
ARG TFLINT_VERSION
ARG TFSEC_VERSION
ARG PYTHON_VERSION
ARG PYTHON_VERSION_TO_USE

RUN \
  # GCP / gcloud Configuration
  wget -q -O /tmp/google-cloud-sdk.tar.gz https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-sdk-${GCLOUD_VERSION}-linux-x86_64.tar.gz && \
  tar -zxvf /tmp/google-cloud-sdk.tar.gz -C /usr/lib/ && \
  /usr/lib/google-cloud-sdk/install.sh --rc-path=/root/.bashrc --command-completion=true --path-update=true --quiet && \
  source ~/.bashrc && \
  gcloud components install beta docker-credential-gcr --quiet && \
#  gcloud config set core/disable_usage_reporting true && \
#  gcloud config set component_manager/disable_update_check true && \
#  gcloud config set metrics/environment github_docker_image && \
  rm -rf /tmp/google-cloud-sdk.tar.gz && \
  \
  # Cleanup
  rm -rf /tmp/* && \
  rm -rf /var/tmp/* && \
  rm -rf ~/.wget-hsts && \
  # Confirm Version
  gcloud --version

ENTRYPOINT ["/bin/bash"]