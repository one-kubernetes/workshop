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

flux bootstrap github --owner=${GITHUB_USER} --repository=${GITHUB_REPO} --team=dev1 --team=dev2 --path=clusters/snowcamp
```
## Clone your repository
By default, `flux boostrap` don't create the folder inside your shell, so you must clone the newly created repository from Github
```bash
git clone https://github.com/<your-organization>/fleet-infra
```
## Create tenants YAML
Now we create the base of the directories that will handle the Flux configuration so that it can manage multiple tenants.
```bash
cd ./fleet-infra
flux create kustomization tenants --namespace=flux-system --source=GitRepository/flux-system --path ./tenants/staging --prune --interval=3m --export >> clusters/snowcamp/tenants.yaml
```
> :warning: Remember to commit and push your code each time you make a change so that FluxCD can apply the changes.
## Onboard dev1 Kustomize
Now, we can create the first tenant, which will be `dev1`
```bash
mkdir -p ./tenants/base/dev1
```
```bash
flux create tenant dev1 --with-namespace=dev1-ns --cluster-role=dev1-full-access --export > ./tenants/base/dev1/rbac.yaml
```
```bash
cat << EOF | tee ./tenants/base/dev1/cluster-role-dev1.yml
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  namespace: dev1-ns
  name: dev1-full-access
rules:
- apiGroups: ["", "extensions", "apps"]
  resources: ["deployments", "replicasets", "pods", "services", "ingresses"]
  verbs: ["get", "list", "watch", "create", "update", "patch", "delete"] # You can also use ["*"]
EOF
```
```bash
flux create source git dev1-aspicot --namespace=dev1-ns --url=https://github.com/one-kubernetes/dev1-aspicot-app/ --branch=main --export > ./tenants/base/dev1/sync.yaml
```
```bash
flux create kustomization dev1 --namespace=dev1-ns --service-account=dev1 --source=GitRepository/dev1-aspicot --path="./" --export >> ./tenants/base/dev1/sync.yaml
```
```bash
cd ./tenants/base/dev1/ && kustomize create --autodetect
```
> :warning: Remember to commit and push your code each time you make a change so that FluxCD can apply the changes.

In your development repository, create the `kustomization.yaml` with `kustomize create --autodetect`.
For this workshop, the `kustomization.yaml` is already created for you.

```bash
mkdir -p ./tenants/staging/dev1
cat << EOF | tee ./tenants/staging/dev1/dev1-patch.yaml
apiVersion: kustomize.toolkit.fluxcd.io/v1beta1
kind: Kustomization
metadata:
  name: dev1
  namespace: dev1-ns
spec:
  path: ./
EOF
```
```bash
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
> :warning: Remember to commit and push your code each time you make a change so that FluxCD can apply the changes.
# Onboard dev2 team
## Create tenant
```bash
mkdir -p ./tenants/base/dev2
flux create tenant dev2 --with-namespace=dev2-ns --cluster-role=dev2-full-access --export > ./tenants/base/dev2/rbac.yaml
```
```bash
cat << EOF | tee ./tenants/base/dev2/cluster-role-dev2.yml
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  namespace: dev2-ns
  name: dev2-full-access
rules:
- apiGroups: ["", "extensions", "apps"]
  resources: ["deployments", "replicasets", "pods", "services", "ingresses"]
  verbs: ["get", "list", "watch", "create", "update", "patch", "delete"] # You can also use ["*"]
EOF
```
## Create flux resources to watch helm charts releases
```bash
flux create source helm charts --url=https://one-kubernetes.github.io/dev2-helm-charts --interval=3m --export > ./tenants/base/dev2/sync.yaml
flux create helmrelease dev2-carapuce --namespace=dev2-ns --service-account=dev2 --source=HelmRepository/charts.flux-system --chart=dev2-carapuce-helm --export >> ./tenants/base/dev2/sync.yaml
cd ./tenants/base/dev2/ && kustomize create --autodetect
```
## Create the patch directory
```bash
mkdir -p ./tenants/staging/dev2

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
      version: "0.1.0"
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
# Enforce use of Service account for HelmRelease and Kustomization
## Download Kyverno distribution
```bash
mkdir -p clusters/snowcamp/kyverno
wget https://raw.githubusercontent.com/kyverno/kyverno/v1.5.4/definitions/release/install.yaml -P clusters/snowcamp/kyverno
```
## Install Kyverno on cluster
```bash
cat << EOF | tee ./cluster/snowcamp/kyverno/kustomization.yaml
---
apiVersion: kustomize.toolkit.fluxcd.io/v1beta2
kind: Kustomization
metadata:
  name: kyverno
  namespace: flux-system
spec:
  interval: 10m
  sourceRef:
    kind: GitRepository
    name: flux-system
  path: ./cluster/snowcamp/kyverno
  prune: true
  wait: true
  timeout: 5m
EOF
```
## Add Kyverno policy to enforce use of Service Account
```bash
mkdir -p cluster/snowcamp/kyverno-policies/
cat << EOF | tee ./cluster/snowcamp/kyverno-policies/enforce-service-account.yaml
---
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: flux-multi-tenancy
spec:
  validationFailureAction: enforce
  rules:
    - name: serviceAccountName
      exclude:
        resources:
          namespaces:
            - flux-system
      match:
        resources:
          kinds:
            - Kustomization
            - HelmRelease
      validate:
        message: ".spec.serviceAccountName is required"
        pattern:
          spec:
            serviceAccountName: "?*"
    - name: kustomizationSourceRefNamespace
      exclude:
        resources:
          namespaces:
            - flux-system
      match:
        resources:
          kinds:
            - Kustomization
      preconditions:
        any:
          - key: "{{request.object.spec.sourceRef.namespace}}"
            operator: NotEquals
            value: ""
      validate:
        message: "spec.sourceRef.namespace must be the same as metadata.namespace"
        deny:
          conditions:
            - key: "{{request.object.spec.sourceRef.namespace}}"
              operator: NotEquals
              value:  "{{request.object.metadata.namespace}}"
    - name: helmReleaseSourceRefNamespace
      exclude:
        resources:
          namespaces:
            - flux-system
      match:
        resources:
          kinds:
            - HelmRelease
      preconditions:
        any:
          - key: "{{request.object.spec.chart.spec.sourceRef.namespace}}"
            operator: NotEquals
            value: ""
      validate:
        message: "spec.chart.spec.sourceRef.namespace must be the same as metadata.namespace"
        deny:
          conditions:
            - key: "{{request.object.spec.chart.spec.sourceRef.namespace}}"
              operator: NotEquals
              value:  "{{request.object.metadata.namespace}}"
EOF
```
## Apply Kyverno policy
```bash
cat << EOF | tee ./cluster/snowcamp/kyverno-policies/kustomization.yaml
---
apiVersion: kustomize.toolkit.fluxcd.io/v1beta2
kind: Kustomization
metadata:
  name: kyverno-policies
  namespace: flux-system
spec:
  dependsOn:
    - name: kyverno
  interval: 5m
  sourceRef:
    kind: GitRepository
    name: flux-system
  path: ./cluster/snowcamp/kyverno-policies
  prune: true
EOF
```
## Add Kyverno dependency for staging tenant
```bash
cat < EOF | tee ./cluster/snowcamp/tenants.yaml
---
apiVersion: kustomize.toolkit.fluxcd.io/v1beta2
kind: Kustomization
metadata:
  name: tenants
  namespace: flux-system
spec:
  dependsOn:
    - name: kyverno-policies
  interval: 5m
  sourceRef:
    kind: GitRepository
    name: flux-system
  path: ./tenants/staging
  prune: true
EOF
```

# Install monitoring stack
## Install kube-prometheus-stack
```bash
flux create source git monitoring \
  --interval=30m \
  --url=https://github.com/fluxcd/flux2 \
  --branch=main
```
## Apply the manifests
```bash
flux create kustomization monitoring-stack \
  --interval=1h \
  --prune=true \
  --source=monitoring \
  --path="./manifests/monitoring/kube-prometheus-stack" \
  --health-check="Deployment/kube-prometheus-stack-operator.monitoring" \
  --health-check="Deployment/kube-prometheus-stack-grafana.monitoring"
```
## Install Flux Grafana dashboards
```bash
flux create kustomization monitoring-config \
  --interval=1h \
  --prune=true \
  --source=monitoring \
  --path="./manifests/monitoring/monitoring-config"
```
## Access the Grafana dashboard
```bash
kubectl -n monitoring port-forward svc/kube-prometheus-stack-grafana 3000:80
```
## Get the Grafana admin password
```bash
kubectl get secret --namespace kube-prometheus-stack kube-prometheus-stack-grafana -o json | jq '.data | map_values(@base64d)'
```

# Image updates