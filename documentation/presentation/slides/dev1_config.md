# Configuration Flux pour déploiement **dev1**

----

## Création du _tenant_ dédié à dev1

```bash [1|2-5|6-17|18-22|23-27|28-29]
$ mkdir -p ./tenants/base/dev1
$ flux create tenant dev1            \
    --with-namespace=dev1-ns         \
    --cluster-role=dev1-full-access  \
    --export > ./tenants/base/dev1/rbac.yaml
$ cat << EOF | tee ./tenants/base/dev1/cluster-role-dev1.yaml
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
$ flux create source git dev1-aspicot
    --namespace=dev1-ns
    --url=https://github.com/one-kubernetes/dev1-aspicot-app/
    --branch=main
    --export > ./tenants/base/dev1/sync.yaml
$ flux create kustomization dev1
    --namespace=dev1-ns
    --service-account=dev1
    --source=GitRepository/dev1-aspicot
    --path="./" --export >> ./tenants/base/dev1/sync.yaml
$ cd ./tenants/base/dev1/
$  kustomize create --autodetect
cd -
```

----

### Synchro avec le dépôt Github

Après git commit && git push, on obtient cette arborescence.

<img class="r-stretch" src="../images/dev1_config_files.jpg">

----

### Création de la kustomization dans le dépôt de dev

<img class="r-stretch" src="../images/one-kubernetes_Sacha.png">

* `Flux` scrute le dépôt de **dev1**, mais il s'attend à y trouver un fichier `kustomization.yaml`
* dev1 doit donc y créer ce fichier

```bash
$ kustomize create --autodetect
```

----

### Ajout d'un patch spécifique à dev1 en staging

<img class="r-stretch" src="../images/one-kubernetes_Sigero.png">

```bash [1|2-10|11-20]
$ mkdir -p ./tenants/staging/dev1
$ cat << EOF | tee ./tenants/staging/dev1/dev1-patch.yaml
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

----

### dev1-aspicot est déployé

<img class="r-stretch" src="../images/dev1_website001.png">

----

### ⚠️ Limitations

* Pour chaque nouveau dépôt applicatif, **ops** doit ajouter une source `Flux`
* **dev1** est celui qui produit le `deployment.yaml`
    * et donc, **ops** a peu de latitude pour configurer des comportements différents entre `staging` et `prod`