# K3S install

more detail here: https://rancher.com/docs/k3s/late st/en/quick-start/

curl -sfL https://get.k3s.io | sh -
sudo chmod o+r /etc/rancher/k3s/k3s.yaml
kubectl get nodes

# Flux v2 install

more detail here: https://fluxcd.io/docs/get-started/

curl -s https://fluxcd.io/install.sh | sudo bash
kubectl create ns flux

export GHUSER="lpiot"
fluxctl install --git-user=${GHUSER} --git-email=${GHUSER}@users.noreply.github.com --git-url=git@github.com:${GHUSER}/flux-get-started --git-path=namespaces,workloads --namespace=flux | kubectl apply -f -

# configure your /.kube/config in order for Flux to access your K3S cluster
ln -s /etc/rancher/k3s/k3s.yaml config

### store the public key into the Github repository
fluxctl identity --k8s-fwd-ns flux

### test flux
flux list-workloads --k8s-fwd-ns=flux


# Test multi-tenant

source: https://github.com/fluxcd/flux2-multi-tenancy/tree/main


flux create tenant dev-team --with-namespace=apps --export > ./tenants/base/dev-team/rbac2.yaml
flux create source git dev-team --namespace=apps --url=https://github.com/one-kubernetes/lpiot-dev-team --branch=main --export > ./tenants/base/dev-team/sync2.yaml
flux create kustomization dev-team --namespace=apps --service-account=dev-team --source=GitRepository/dev-team --path="./" --export >> ./tenants/base/dev-team/sync2.yaml

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
