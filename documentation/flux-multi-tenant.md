# Flux - multi tenant

## First install

First of all, you can check that your `Flux` _CLI_ is able to communicate with your `Kubernetes` _cluster_.

```bash
flux check --pre
```

Now you will perform the initial configuration of `Flux`.  
To do so, you must generate a `Github` _token_ so that `Flux` is able to interact with your repository.

As you can see, we indicate two teams (`dev1` and `dev2`) that will be allowed to access the **Github** repository.  
These teams must already exist in your **Github** organization.

```bash
export GITHUB_TOKEN="<insert your Github personal token here>"
export GITHUB_USER="one-kubernetes"
export GITHUB_REPO="fleet-infra"

flux bootstrap github --owner=${GITHUB_USER} --repository=${GITHUB_REPO} --team=dev1 --team=dev2 --path=clusters/devfestnantes
```

## Create tenants YAML

Now we create the base of the directories that will handle the Flux configuration so that it can manage multiple tenants.

```bash
cd ./fleet-infra
flux create kustomization tenants --namespace=flux-system --source=GitRepository/flux-system --path ./tenants/staging --prune --interval=3m --export >> clusters/devfestnantes/tenants.yaml
```

## Onboard dev1 kustomize

```bash
mkdir -p ./tenants/base/dev1

flux create tenant dev1 --with-namespace=dev1-ns --export > ./tenants/base/dev1/rbac.yaml

flux create source git dev1-aspicot --namespace=dev1-ns --url=https://github.com/one-kubernetes/dev1-aspicot-app/ --branch=main --export > ./tenants/base/dev1/sync.yaml

flux create kustomization dev1 --namespace=dev1-ns --service-account=dev1 --source=GitRepository/dev1-aspicot --path="./" --export >> ./tenants/base/dev1/sync.yaml

cd ./tenants/base/dev1/ && kustomize create --autodetect


In the repo laurentgrangeau, create the `kustomization.yaml` with `kustomize create --autodetect`


cat << EOF | tee ./tenants/staging/dev1/dev1-patch.yaml
apiVersion: kustomize.toolkit.fluxcd.io/v1beta1
kind: Kustomization
metadata:
  name: dev1
  namespace: dev1-ns
spec:
  path: ./
EOF

cat << EOF | tee ./tenants/staging/dev1/kustomization.yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
resources:
  - ../../base/dev1
patches:
  - path: dev1-patch.yaml
    target:
      kind: Kustomization
EOF
```

# Onboard dev2 team

## create tenant

```bash
mkdir -p ./tenants/base/dev2
flux create tenant dev2 --with-namespace=dev2-ns --export > ./tenants/base/dev2/rbac.yaml
```

## create flux resources to watch helm charts releases

```bash
flux create source helm charts --url=https://one-kubernetes.github.io/dev2-helm-charts --interval=3m --export > ./tenants/base/dev2/sync.yaml

flux create helmrelease dev2-carapuce --namespace=dev2-ns --service-account=dev2 --source=HelmRepository/charts.flux-system --chart=dev2-carapuce-helm --export >> ./tenants/base/dev2/sync.yaml
```

## create the patch directory

```bash
cd ./tenants/staging/dev2/ && kustomize create --autodetect

cat << EOF | tee ./tenants/staging/dev2/dev2-patch.yaml
apiVersion: helm.toolkit.fluxcd.io/v2beta1
kind: HelmRelease
metadata:
  name: dev2-carapuce
  namespace: dev2-ns
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

cat << EOF | tee ./tenants/staging/dev2/kustomization.yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
resources:
  - ../../base/dev2
patches:
  - path: dev2-patch.yaml
    target:
      kind: Kustomization
EOF
```
