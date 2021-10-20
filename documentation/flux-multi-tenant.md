## Bootstrap Flux
flux check --pre

export GITHUB_TOKEN="<insert your Github personal token here>"

flux bootstrap github --owner=one-kubernetes --repository=fleet-infra --team=dev-team1 --team=dev-team2 --path=clusters/devfestnantes

## Create tenants YAML
flux create kustomization tenants --namespace=flux-system --source=GitRepository/flux-system --path ./tenants/staging --prune --interval=5m --export >> clusters/devfestnantes/tenants.yaml

## Onboard dev-team1 kustomize
mkdir -p ./tenants/base/dev-team1

flux create tenant dev-team1 --with-namespace=apps-dev-team1 --export > ./tenants/base/dev-team1/rbac.yaml

flux create source git dev-team1 --namespace=apps-dev-team1 --url=https://github.com/laurentgrangeau/docker-kubernetes-hello-world/ --branch=master --export > ./tenants/base/dev-team1/sync.yaml

flux create kustomization dev-team1 --namespace=apps-dev-team1 --service-account=dev-team1 --source=GitRepository/dev-team1 --path="./" --export >> ./tenants/base/dev-team1/sync.yaml

In the repo laurentgrangeau, create the `kustomization.yaml` with `kustomize create --autodetect`

cd ./tenants/base/dev-team1/ && kustomize create --autodetect

cat << EOF | tee ./tenants/staging/dev-team1/dev-team1-patch.yaml
apiVersion: kustomize.toolkit.fluxcd.io/v1beta1
kind: Kustomization
metadata:
  name: dev-team1
  namespace: apps-dev-team1
spec:
  path: ./
EOF

cat << EOF | tee ./tenants/staging/dev-team1/kustomization.yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
resources:
  - ../base/dev-team1
patches:
  - path: dev-team1-patch.yaml
    target:
      kind: Kustomization
EOF

## Onboard dev-team2 helm
mkdir -p ./tenants/base/dev-team2

flux create tenant dev-team2 --with-namespace=apps-dev-team2 --export > ./tenants/base/dev-team2/rbac.yaml

flux create source helm charts --url=https://one-kubernetes.github.io/helm-charts/ --interval=10m --export >> ./tenants/base/dev-team2/sync.yaml

flux create helmrelease dev-team2 --namespace=apps-dev-team2 --service-account=dev-team2 --source=HelmRepository/charts.flux-system --chart=hellodevfestnantes --export >> ./tenants/base/dev-team2/sync.yaml

cd ./tenants/base/dev-team2/ && kustomize create --autodetect

cat << EOF | tee ./tenants/staging/dev-team2/dev-team2-patch.yaml
apiVersion: helm.toolkit.fluxcd.io/v2beta1
kind: HelmRelease
metadata:
  name: podinfo
  namespace: podinfo
spec:
  chart:
    spec:
      version: ">=1.0.0-alpha"
  test:
    enable: false
  values:
    ingress:
      hosts:
        - host: podinfo.staging
          paths:
            - path: /
              pathType: ImplementationSpecific
EOF

cat << EOF | tee ./tenants/staging/dev-team2/kustomization.yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
resources:
  - ../../base/dev-team2
patches:
  - path: dev-team2-patch.yaml
    target:
      kind: Kustomization
EOF

## Add Loki stack