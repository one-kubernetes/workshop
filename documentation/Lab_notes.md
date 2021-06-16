# K3S install

more detail here: https://rancher.com/docs/k3s/late st/en/quick-start/

curl -sfL https://get.k3s.io | sh -
sudo chmod o+r /etc/rancher/k3s/k3s.yaml
kubectl get nodes

# Flux v2 install

more detail here: https://fluxcd.io/docs/get-started/

curl -s https://fluxcd.io/install.sh | sudo bash
kubectl create ns flux

export GITHUB_TOKEN="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"
export GITHUB_USER="lpiot"
export GITHUB_REPO="one-kubernetes/flux2-kustomize-helm-example"

flux check --pre

flux bootstrap github --context=staging --owner=${GITHUB_USER} --repository=${GITHUB_REPO} --branch=main --personal --path=clusters/staging


# configure your /.kube/config in order for Flux to access your K3S cluster
ln -s /etc/rancher/k3s/k3s.yaml ~/.kube/config

### store the public key into the Github repository
fluxctl identity --k8s-fwd-ns flux

### test flux
flux list-workloads --k8s-fwd-ns=flux

# kustomize install

more detail here: https://kubectl.docs.kubernetes.io/installation/kustomize/

curl -s "https://raw.githubusercontent.com/kubernetes-sigs/kustomize/master/hack/install_kustomize.sh"  | bash


# Test multi-tenant

source: https://github.com/fluxcd/flux2-multi-tenancy/tree/main

mkdir -p ./tenants/base/dev-team/ ./tenants/staging/ ./tenants/production
flux create tenant dev-team --with-namespace=apps --export > ./tenants/base/dev-team/rbac.yaml
flux create source git dev-team --namespace=apps --url=https://github.com/one-kubernetes/lpiot-test-dev-team --branch=main --export > ./tenants/base/dev-team/sync.yaml
flux create kustomization dev-team --namespace=apps --service-account=dev-team --source=GitRepository/dev-team --path="./" --export >> ./tenants/base/dev-team/sync.yaml
cd ./tenants/base/dev-team/ && kustomize create --autodetect

cat << EOF | tee ./tenants/staging/dev-team-patch.yaml
apiVersion: kustomize.toolkit.fluxcd.io/v1beta1
kind: Kustomization
metadata:
  name: dev-team
  namespace: apps
spec:
  path: ./staging
EOF

cat << EOF | tee ./tenants/staging/kustomization.yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
resources:
  - ../base/dev-team
patchesStrategicMerge:
  - dev-team-patch.yaml
EOF
