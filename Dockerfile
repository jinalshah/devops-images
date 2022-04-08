ARG GCLOUD_VERSION=380.0.0
ARG PACKER_VERSION=1.8.0
ARG TERRAGRUNT_VERSION=0.36.6
ARG TFLINT_VERSION=0.35.0
ARG TFSEC_VERSION=1.17.0
ARG PYTHON_VERSION=3.8.13
ARG PYTHON_VERSION_TO_USE=python3.8

FROM rockylinux:latest AS base

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

COPY scripts/*.sh /tmp/

RUN \
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
    findutils \
    git \
    jq \
    less \
    make \
    openssh-clients \
    python3 \
    sqlite-devel \
    tree \
    vim \
    wget \
    unzip \
    yum-utils \
    zip \
    zsh \
    && \
  \
  # GitHub CLI
  yum-config-manager --add-repo https://cli.github.com/packages/rpm/gh-cli.repo && \
  yum install -y gh && \
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
  \
  # Set Python "PYTHON_VERSION_TO_USE" as default
  alternatives --install /usr/bin/python3 python3 /usr/local/bin/${PYTHON_VERSION_TO_USE} 100 && \
  echo 2 | alternatives --config python3 && \
  \
  python3 -m pip install --upgrade -U pip  && \
  \
  python3 -m pip install --upgrade ansible && \
  python3 -m pip install --upgrade ansible-lint[yamllint] && \
  python3 -m pip install --upgrade mkdocs-material && \
  python3 -m pip install --upgrade paramiko && \
  python3 -m pip install --upgrade pre-commit && \
  \
  # Ansible Configuration
  mkdir -p /etc/ansible/roles && \
  wget -q -O /etc/ansible/ansible.cfg https://raw.githubusercontent.com/ansible/ansible/devel/examples/ansible.cfg && \
  wget -q -O /etc/ansible/hosts https://raw.githubusercontent.com/ansible/ansible/devel/examples/hosts && \
  \
  # Download, Install and Configure OhMyZsh
  sh -c "$(wget -O- https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" && \
  sed -i 's/ZSH_THEME=\"robbyrussell\"/ZSH_THEME=\"candy\"/g' ~/.zshrc && \
  \
  # Customisations
  # useradd devops && \
  # \
  . /tmp/10-zshrc.sh && \
  . /tmp/20-bashrc.sh && \
  \
  chmod +x /tmp/30-clone-all-repos.sh && \
  mv /tmp/30-clone-all-repos.sh /usr/local/bin/clone-all-repos && \
  \
  # Cleanup \
  yum clean packages && \
  yum clean metadata && \
  yum clean all && \
  rm -rf /tmp/* && \
  rm -rf /var/tmp/* && \
  rm -rf $(find / -regex ".*/__pycache__") && \
  rm -rf /root/.cache/pip/* && \
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
  rm -rf /root/.cache/pip/* && \
  rm -rf ~/.wget-hsts && \
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

#;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
#;;                                                                            ;;
#;;              ----==| A L L   D E V O P S   I M A G E |==----               ;;
#;;                                                                            ;;
#;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

FROM base AS all-devops

ARG GCLOUD_VERSION
ARG PACKER_VERSION
ARG TERRAGRUNT_VERSION
ARG TFLINT_VERSION
ARG TFSEC_VERSION
ARG PYTHON_VERSION
ARG PYTHON_VERSION_TO_USE

SHELL ["/bin/bash", "-c"]
RUN \
  # AWS Python Requirements
  python3 -m pip install --upgrade --no-cache-dir -U crcmod && \
  python3 -m pip install --upgrade pytest && \
  python3 -m pip install --upgrade s3cmd && \
  python3 -m pip install --upgrade boto3 && \
  python3 -m pip install --upgrade cfn-lint && \
  python3 -m pip install --upgrade requests && \
  python3 -m pip install --upgrade bs4 && \
  python3 -m pip install --upgrade lxml && \
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
  /usr/lib/google-cloud-sdk/install.sh --rc-path=/root/.zshrc --command-completion=true --path-update=true --quiet && \
  gcloud components install beta docker-credential-gcr --quiet && \
  gcloud config set core/disable_usage_reporting true && \
  # gcloud config set component_manager/disable_update_check true && \
  rm -rf /usr/lib/google-cloud-sdk/.install/.backup && \
  rm -rf /tmp/google-cloud-sdk.tar.gz && \
  \
  # Cleanup
  rm -rf /tmp/* && \
  rm -rf /var/tmp/* && \
  rm -rf $(find / -regex ".*/__pycache__") && \
  rm -rf /root/.cache/pip/* && \
  rm -rf ~/.wget-hsts && \
  # Confirm Version
  aws --version && \
  gcloud --version

ENTRYPOINT ["/bin/zsh"]

#;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
#;;                                                                            ;;
#;;              ----==| A W S   D E V O P S   I M A G E |==----               ;;
#;;                                                                            ;;
#;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

FROM base AS aws-devops

ARG GCLOUD_VERSION
ARG PACKER_VERSION
ARG TERRAGRUNT_VERSION
ARG TFLINT_VERSION
ARG TFSEC_VERSION
ARG PYTHON_VERSION
ARG PYTHON_VERSION_TO_USE

SHELL ["/bin/bash", "-c"]
RUN \
  # AWS Python Requirements
  python3 -m pip install --upgrade --no-cache-dir -U crcmod && \
  python3 -m pip install --upgrade pytest && \
  python3 -m pip install --upgrade s3cmd && \
  python3 -m pip install --upgrade boto3 && \
  python3 -m pip install --upgrade cfn-lint && \
  python3 -m pip install --upgrade requests && \
  python3 -m pip install --upgrade bs4 && \
  python3 -m pip install --upgrade lxml && \
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
  rm -rf $(find / -regex ".*/__pycache__") && \
  rm -rf /root/.cache/pip/* && \
  # Confirm Version
  aws --version

ENTRYPOINT ["/bin/zsh"]

#;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
#;;                                                                            ;;
#;;              ----==| G C P   D E V O P S   I M A G E |==----               ;;
#;;                                                                            ;;
#;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


FROM base AS gcp-devops

ARG GCLOUD_VERSION
ARG PACKER_VERSION
ARG TERRAGRUNT_VERSION
ARG TFLINT_VERSION
ARG TFSEC_VERSION
ARG PYTHON_VERSION
ARG PYTHON_VERSION_TO_USE

SHELL ["/bin/bash", "-c"]
RUN \
  # GCP / gcloud Configuration
  wget -q -O /tmp/google-cloud-sdk.tar.gz https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-sdk-${GCLOUD_VERSION}-linux-x86_64.tar.gz && \
  tar -zxvf /tmp/google-cloud-sdk.tar.gz -C /usr/lib/ && \
  /usr/lib/google-cloud-sdk/install.sh --rc-path=/root/.zshrc --command-completion=true --path-update=true --quiet && \
  gcloud components install beta docker-credential-gcr --quiet && \
  gcloud config set core/disable_usage_reporting true && \
  # gcloud config set component_manager/disable_update_check true && \
  rm -rf /usr/lib/google-cloud-sdk/.install/.backup && \
  rm -rf /tmp/google-cloud-sdk.tar.gz && \
  \
  # Cleanup
  rm -rf /tmp/* && \
  rm -rf /var/tmp/* && \
  rm -rf $(find / -regex ".*/__pycache__") && \
  rm -rf /root/.cache/pip/* && \
  rm -rf ~/.wget-hsts && \
  # Confirm Version
  gcloud --version

ENTRYPOINT ["/bin/zsh"]