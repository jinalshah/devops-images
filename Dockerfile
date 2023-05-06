ARG GCLOUD_VERSION=429.0.0             # https://cloud.google.com/sdk/docs/install
ARG PACKER_VERSION=1.8.7               # https://developer.hashicorp.com/packer/downloads
ARG TERRAGRUNT_VERSION=0.45.9          # https://github.com/gruntwork-io/terragrunt
ARG TFLINT_VERSION=0.46.1              # https://github.com/terraform-linters/tflint
ARG TFSEC_VERSION=1.28.1               # https://github.com/aquasecurity/tfsec
ARG GHORG_VERSION=1.9.4                # https://github.com/gabrie30/ghorg
ARG PYTHON_VERSION=3.8.13
ARG PYTHON_VERSION_TO_USE=python3.8
ARG MONGODB_VERSION=6.0
ARG MONGODB_REPO_PATH=/etc/yum.repos.d/mongodb-org-${MONGODB_VERSION}.repo

## Determine OS Architecture
# Use this var if you want to retrieve "arm64" insteaf of "aarch64". If you need aarch64 simply use `uname -m` in the command instead.
# This also sets amd64 for amd64 instead of x86_64 based architectures
ARG ARCH_VALUE=$(arch=$(uname -m); if [ "$arch" = "aarch64" ]; then echo "arm64"; elif [ "$arch" = "x86_64" ]; then echo "amd64"; else echo "unknown"; fi)
# Same as above but sets x86_64 for amd64 instead of amd64 based architectures
ARG GHORG_ARCH_VALUE=$(arch=$(uname -m); if [ "$arch" = "aarch64" ]; then echo "arm64"; elif [ "$arch" = "x86_64" ]; then echo "x86_64"; else echo "unknown"; fi)
# Use this to obtain "arm" instead of "arm64" and set x86_64 for amd64 based architectures.
ARG GCLOUD_ARCH_VALUE=$(arch=$(uname -m); [ "$arch" = "aarch64" ] && echo "arm" || echo "x86_64")

FROM rockylinux:9 AS base

LABEL name=devops

ARG GCLOUD_VERSION
ARG PACKER_VERSION
ARG TERRAGRUNT_VERSION
ARG TFLINT_VERSION
ARG TFSEC_VERSION
ARG PYTHON_VERSION
ARG PYTHON_VERSION_TO_USE
ARG GHORG_VERSION
ARG MONGODB_VERSION
ARG MONGODB_REPO_PATH

ENV CLOUDSDK_PYTHON=python3
ENV PATH /usr/lib/google-cloud-sdk/bin:$PATH

COPY scripts/*.sh /tmp/

RUN \
  # Install Packages via Yum
  yum install --allowerasing -y \
    glibc-langpack-en \
    epel-release \
    && \
  \
  yum install --allowerasing -y \
    bash \
    bash-completion \
    curl \
    findutils \
    git \
    jq \
    less \
    make \
    mysql \
    openssh-clients \
    python3-pip \
    python3-dnf \
    sqlite-devel \
    tree \
    vim \
    wget \
    unzip \
    yum-utils \
    zip \
    zsh \
    && \
  # Update All Components
  yum update -y && \
  \
  # GitHub CLI
  yum-config-manager --add-repo https://cli.github.com/packages/rpm/gh-cli.repo && \
  yum install --allowerasing -y gh && \
  \
  # Install binaries to compile Python 3.8
  yum install --allowerasing -y \
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
  tar -zxf Python-${PYTHON_VERSION}.tgz && \
  cd Python-${PYTHON_VERSION} && \
  ./configure --enable-optimizations && \
  make altinstall && \
  cd /tmp && \
  rm -rf Python* && \
  \
  python3 -m pip install --upgrade -U pip  && \
  \
  # # Set Python "PYTHON_VERSION_TO_USE" as default
  # alternatives --install /usr/bin/python3 python3 /usr/local/bin/${PYTHON_VERSION_TO_USE} 100 && \
  # alternatives --install /usr/bin/python3 python3 /usr/bin/python3.9 200 && \
  # echo 1 | alternatives --config python3 && \
  # \
  python3 -m pip install --upgrade -U pip  && \
  \
  python3 -m pip install --upgrade ansible && \
  python3 -m pip install --upgrade ansible-lint[yamllint] && \
  python3 -m pip install --upgrade jmespath && \
  python3 -m pip install --upgrade mkdocs-material && \
  python3 -m pip install --upgrade paramiko && \
  python3 -m pip install --upgrade pre-commit && \
  \
  # Ansible Configuration
  mkdir -p /etc/ansible/roles && \
  wget -q -O /etc/ansible/ansible.cfg https://raw.githubusercontent.com/ansible/ansible/devel/examples/ansible.cfg && \
  wget -q -O /etc/ansible/hosts https://raw.githubusercontent.com/ansible/ansible/devel/examples/hosts && \
  \
  # MongoDB-MongoSH Installation
  touch ${MONGODB_REPO_PATH} && \
  echo "[mongodb-org-${MONGODB_VERSION}]" >> ${MONGODB_REPO_PATH} && \
  echo "name=MongoDB Repository" >> ${MONGODB_REPO_PATH} && \
  echo "baseurl=https://repo.mongodb.org/yum/redhat/\$releasever/mongodb-org/${MONGODB_VERSION}/$(uname -m)/" >> ${MONGODB_REPO_PATH} && \
  echo "gpgcheck=1" >> ${MONGODB_REPO_PATH} && \
  echo "enabled=1" >> ${MONGODB_REPO_PATH} && \
  echo "gpgkey=https://www.mongodb.org/static/pgp/server-${MONGODB_VERSION}.asc" >> ${MONGODB_REPO_PATH} && \
  yum install --allowerasing -y mongodb-mongosh && \
  \
  # Install PostgreSQL Client
  yum install --allowerasing -y \
    https://download.postgresql.org/pub/repos/yum/reporpms/EL-9-$(uname -m)/pgdg-redhat-repo-latest.noarch.rpm && \
  # yum module -y disable postgresql && \
  yum install --allowerasing -y \
    postgresql14 \
    && \
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
  wget -q -O /tmp/kubectl https://storage.googleapis.com/kubernetes-release/release/`curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt`/bin/linux/${ARCH_VALUE}/kubectl && \
  chmod +x /tmp/kubectl && \
  mv /tmp/kubectl /usr/local/bin && \
  \
  # Install tfswitch and Install latest version of Terraform
  curl -L https://raw.githubusercontent.com/warrensbox/terraform-switcher/release/install.sh | bash && \
  tfswitch --latest && \
  \
  wget -qO /tmp/terragrunt https://github.com/gruntwork-io/terragrunt/releases/download/v${TERRAGRUNT_VERSION}/terragrunt_linux_${ARCH_VALUE} && \
  chmod +x /tmp/terragrunt && \
  mv /tmp/terragrunt /usr/local/bin && \
  \
  wget -qO /tmp/tflint.zip https://github.com/terraform-linters/tflint/releases/download/v${TFLINT_VERSION}/tflint_linux_${ARCH_VALUE}.zip && \
  unzip -q /tmp/tflint.zip -d /tmp && \
  chmod +x /tmp/tflint && \
  mv /tmp/tflint /usr/local/bin && \
  \
  wget -qO /tmp/tfsec https://github.com/liamg/tfsec/releases/download/v${TFSEC_VERSION}/tfsec-linux-${ARCH_VALUE} && \
  chmod +x /tmp/tfsec && \
  mv /tmp/tfsec /usr/local/bin && \
  \
  wget -qO /tmp/packer.zip https://releases.hashicorp.com/packer/${PACKER_VERSION}/packer_${PACKER_VERSION}_linux_${ARCH_VALUE}.zip && \
  unzip -q /tmp/packer.zip -d /tmp && \
  chmod +x /tmp/packer && \
  mv /tmp/packer /usr/local/bin && \
  \
  # Install ghorg
  wget -qO /tmp/ghorg.tar.gz https://github.com/gabrie30/ghorg/releases/download/v${GHORG_VERSION}/ghorg_${GHORG_VERSION}_Linux_${GHORG_ARCH_VALUE}.tar.gz && \
  mkdir /tmp/ghorg && \
  tar -zxf /tmp/ghorg.tar.gz -C /tmp/ghorg && \
  chmod +x /tmp/ghorg/ghorg && \
  mv /tmp/ghorg/ghorg /usr/local/bin && \
  rm -rf /tmp/ghorg && \
  mkdir -p $HOME/.config/ghorg && \
  curl https://raw.githubusercontent.com/gabrie30/ghorg/master/sample-conf.yaml > $HOME/.config/ghorg/conf.yaml && \
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
  curl "https://awscli.amazonaws.com/awscli-exe-linux-$(uname -m).zip" -o "awscliv2.zip" && \
  unzip -q awscliv2.zip && \
  /tmp/aws/install && \
  \
  # AWS Session Manager Plugin Installation
  cd /tmp && \
  curl "https://s3.amazonaws.com/session-manager-downloads/plugin/latest/linux_64bit/session-manager-plugin.rpm" -o "session-manager-plugin.rpm" && \
  yum install --allowerasing -y session-manager-plugin.rpm && \
  \
  # GCP / gcloud Configuration
  wget -q -O /tmp/google-cloud-sdk.tar.gz https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-sdk-${GCLOUD_VERSION}-linux-${GCLOUD_ARCH_VALUE}.tar.gz && \
  tar -zxf /tmp/google-cloud-sdk.tar.gz -C /usr/lib/ && \
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
  curl "https://awscli.amazonaws.com/awscli-exe-linux-$(uname -m).zip" -o "awscliv2.zip" && \
  unzip -q awscliv2.zip && \
  /tmp/aws/install && \
  \
  # AWS Session Manager Plugin Installation
  cd /tmp && \
  curl "https://s3.amazonaws.com/session-manager-downloads/plugin/latest/linux_64bit/session-manager-plugin.rpm" -o "session-manager-plugin.rpm" && \
  yum install --allowerasing -y session-manager-plugin.rpm && \
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
  wget -q -O /tmp/google-cloud-sdk.tar.gz "https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-sdk-${GCLOUD_VERSION}-linux-${GCLOUD_ARCH_VALUE}.tar.gz" && \
  tar -zxf /tmp/google-cloud-sdk.tar.gz -C /usr/lib/ && \
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