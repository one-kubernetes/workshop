# -----------------------------------------------------------------------------
# Terraform
# -----------------------------------------------------------------------------
FROM alpine:latest as tf
LABEL maintainer="Ludovic Piot <ludovic.piot@thegaragebandofit.com>"

# Terraform vars
ARG TERRAFORM_VERSION=1.0.0

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
FROM alpine:latest as pac
LABEL maintainer="Ludovic Piot <ludovic.piot@thegaragebandofit.com>"

# Packer vars
ARG PACKER_VERSION=1.7.2

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
FROM mcr.microsoft.com/azure-cli
LABEL maintainer="Ludovic Piot <ludovic.piot@thegaragebandofit.com>"

COPY --from=tf /usr/bin/terraform /usr/bin/terraform
COPY --from=tf /root/.bashrc /root/.bashrc_tf

COPY --from=pac /usr/bin/packer /usr/bin/packer
COPY --from=pac /root/.bashrc /root/.bashrc_pac

RUN cat /root/.bashrc_tf /root/.bashrc_pac >> /root/.bashrc

# Helm install
# more details here: https://helm.sh/docs/intro/install/

RUN curl https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 | bash

# Kustomize install
# more detail here: https://kubectl.docs.kubernetes.io/installation/kustomize/

RUN curl -s "https://raw.githubusercontent.com/kubernetes-sigs/kustomize/master/hack/install_kustomize.sh"  | bash && \
    mv kustomize /usr/local/bin

# Flux install
# more detail here: https://fluxcd.io/docs/get-started/

RUN curl -s https://fluxcd.io/install.sh | bash

# Kubectl install

RUN curl -LO https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl && \
    chmod +x ./kubectl && \
    mv ./kubectl /usr/local/bin/kubectl

# common tools install

RUN apk add jq tmux vim yq
