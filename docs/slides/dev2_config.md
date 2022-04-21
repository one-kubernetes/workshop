# Configuration Flux pour déploiement **dev2**

----

## Création du _tenant_ dédié à **dev2**

Créer le tenant dédié à **dev2** se fait de la même manière que pour **dev1**

1. création de l'arborescence de configuration du _tenant_
2. création du _namespace_
3. isolation du _namespace_ (ServiceAccount, RoleBinding, Role)

----

## Création de la source `Helm` dédiée à **dev2**

⚠️ Là par contre, les choses changent !

On ne se source plus depuis un dépôt `git` mais depuis un dépôt de _charts_ `Helm`

```bash [1-4|6-12][14]
$ flux create source helm charts
    --url=https://one-kubernetes.github.io/dev2-helm-charts
    --interval=3m
    --export > ./tenants/base/dev2/sync.yaml

$ flux create helmrelease dev2-carapuce
    --namespace=dev2-ns
    --service-account=dev2
    --source=HelmRepository/charts.flux-system
    --chart=dev2-carapuce-helm
    --chart-version="0.1.0"
    --export >> ./tenants/base/dev2/sync.yaml

$ cd ./tenants/base/dev2/ && kustomize create --autodetect
```

----

### 📄 ./tenants/base/dev2/sync.yaml

```yaml [1-9|11-16|17-27]
---
apiVersion: source.toolkit.fluxcd.io/v1beta1
kind: HelmRepository
metadata:
  name: charts
  namespace: dev2-ns
spec:
  interval: 3m0s
  url: https://one-kubernetes.github.io/dev2-helm-charts

---
apiVersion: helm.toolkit.fluxcd.io/v2beta1
kind: HelmRelease
metadata:
  name: dev2-carapuce
  namespace: dev2-ns
spec:
  chart:
    spec:
      chart: dev2-carapuce-helm
      sourceRef:
        kind: HelmRepository
        name: charts
        namespace: dev2-ns
      version: 0.1.0
  interval: 1m0s
  serviceAccountName: dev2
```

----

### Synchro avec le dépôt Github

Après git commit && git push, on obtient cette arborescence.

<img class="r-stretch" src="images/dev2_config_files.jpg">
