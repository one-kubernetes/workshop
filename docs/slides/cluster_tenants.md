## Création d'une config. `staging` et `prod`

<img class="r-stretch" src="images/one-kubernetes_Sigero.png">

* **ops** va scinder son _cluster_ en 2 : `staging` et `prod`
* Grace à _Kustomize_, elle va
  1. créer une config. de base
  2. qui sera surchargée par une config. spécifique au _tenant_
* 💡Ça paraît compliqué, mais pas d'inquiétude : la _CLI_ `Flux` s'occupe de l'essentiel

----

<img class="r-stretch" src="images/cluster_multi_tenants.jpg">

----

```bash [1|2-8]
$ cd ./fleet-infra
$ flux create kustomization tenants    \
    --namespace=flux-system            \
    --source=GitRepository/flux-system \
    --path ./tenants/staging           \
    --prune                            \
    --interval=3m                      \
    --export >> clusters/mycluster/tenants.yaml
```

----

### 📄 tenants.yaml

```yaml
---
apiVersion: kustomize.toolkit.fluxcd.io/v1beta2
kind: Kustomization
metadata:
  name: tenants
  namespace: flux-system
spec:
  interval: 5m0s
  path: ./tenants/staging
  prune: true
  sourceRef:
    kind: GitRepository
    name: flux-system
```

----

> ⚠️ N'oubliez pas de `git commit` et `git push` vers Github : c'est la source qui va être scrutée par `Flux`.

