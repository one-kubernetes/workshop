# -----------------------------------------------------------------------------
# Base install
# -----------------------------------------------------------------------------
FROM ubuntu:20.04 as base
LABEL maintainer="Ludovic Piot <ludovic.piot@thegaragebandofit.com>"

RUN apt-get update -y
RUN apt-get install -y wget unzip


# -----------------------------------------------------------------------------
# Terraform
# -----------------------------------------------------------------------------
FROM base as tf
LABEL maintainer="Ludovic Piot <ludovic.piot@thegaragebandofit.com>"

# Terraform vars
ARG TERRAFORM_VERSION=1.1.4

# Terraform install
WORKDIR /usr/bin
RUN wget https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip && \
    unzip ./terraform_${TERRAFORM_VERSION}_linux_amd64.zip && \
    rm -f ./terraform_${TERRAFORM_VERSION}_linux_amd64.zip

# Add Terraform autocompletion in BASH
RUN touch ~/.bashrc && \
    terraform --install-autocomplete

# -----------------------------------------------------------------------------
# Packer
# -----------------------------------------------------------------------------
FROM base as pac
LABEL maintainer="Ludovic Piot <ludovic.piot@thegaragebandofit.com>"

# Packer vars
ARG PACKER_VERSION=1.7.9

# Packer install
WORKDIR /usr/bin
RUN wget https://releases.hashicorp.com/packer/${PACKER_VERSION}/packer_${PACKER_VERSION}_linux_amd64.zip && \
    unzip ./packer_${PACKER_VERSION}_linux_amd64.zip && \
    rm -f ./packer_${PACKER_VERSION}_linux_amd64.zip

# Add Packer autocompletion in BASH
RUN touch ~/.bashrc && \
    packer -autocomplete-install

# -----------------------------------------------------------------------------
# Final Image
# -----------------------------------------------------------------------------
FROM gitpod/workspace-full
LABEL maintainer="Ludovic Piot <ludovic.piot@thegaragebandofit.com>"

WORKDIR /home/gitpod
COPY --from=tf /usr/bin/terraform /usr/bin/terraform
COPY --from=tf /root/.bashrc ./.bashrc_tf

COPY --from=pac /usr/bin/packer /usr/bin/packer
COPY --from=pac /root/.bashrc ./.bashrc_pac

RUN cat ./.bashrc_tf ./.bashrc_pac >> ./.bashrc

# Helm install
# more details here: https://helm.sh/docs/intro/install/

RUN curl https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 | bash

# Kustomize install
# more detail here: https://kubectl.docs.kubernetes.io/installation/kustomize/

RUN curl -s "https://raw.githubusercontent.com/kubernetes-sigs/kustomize/master/hack/install_kustomize.sh"  | bash && \
    sudo mv kustomize /usr/local/bin

# Flux install
# more detail here: https://fluxcd.io/docs/get-started/

RUN curl -s https://fluxcd.io/install.sh | bash


# Kubectl install

RUN curl -LO https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl && \
    chmod +x ./kubectl && \
    sudo mv ./kubectl /usr/local/bin/kubectl

# common tools install
RUN sudo apt-get update -y
RUN sudo apt-get install -y jq tmux vim #yq
