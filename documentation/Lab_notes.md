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

``` mermaid
sequenceDiagram
    participant d1 as Dev 1
    participant git as Github
    participant azd as Azure DevOps
    participant acr as ACR (container registry)
    participant acrh as (helm charts repository)
    participant k8sd1 as k8s namespace Dev 1
    participant fcrd as Flux CRDs
    participant fope as Flux operator
    participant o1 as Ops 1
    participant d2 as Dev 2
    participant k8sd2 as k8s namespace Dev 2

    d1->>git: push App_v1 @main
    Activate azd
    azd-->>git: trigger CI-pipeline
    azd->>acr: push Docker image of App_v1
    azd->>acrh: push Helm Chart of App_v1
    azd->>k8sd1: Helm install of App_v1
    Deactivate azd
    o1-)fcrd: Define Source Helm Charts Repository for App_v1
    Activate fcrd
    fope-->>fcrd: Get reconciliation config.    
    fope--)acrh: source Helm repo to detect any new version of Helm Chart
    fope->>k8sd1: upgrade Helm Release to deploy new version of Helm Chart
    Deactivate fcrd

    d2->>git: push App_v1 @main
    Activate azd
    azd-->>git: trigger CI-pipeline
    azd->>acr: push Docker image of App_v1
    azd->>acrh: push Helm Chart of App_v1
    azd->>k8sd2: Helm install of App_v1
    Deactivate azd
    o1-)fcrd: Define Source Helm Charts Repository for App_v2
    Activate fcrd
    fope-->>fcrd: Get reconciliation config.    
    fope--)acrh: source Helm repo to detect any new version of Helm Chart
    fope->>k8sd2: upgrade Helm Release to deploy new version of Helm Chart
    Deactivate fcrd
```

export location='eastus'
export rg='k8s-lab'
export aks='k8s-staging'
export acr='CloudOuestK8sLabRegistry'

# Create a resource group $rg on a specific location $location (for example eastus) which will contain the Azure services we need 
az group create -l $location -n $rg
# Create an ACR registry $acr
az acr create -n $acr -g $rg -l $location --sku Basic

# Setup of the AKS cluster
latestK8sVersion=$(az aks get-versions -l $location --query 'orchestrators[-1].orchestratorVersion' -o tsv)
echo $latestK8sVersion
# todo: reduce cluster to a single node
az aks create -l $location -n $aks -g $rg --generate-ssh-keys -k $latestK8sVersion
# Once created (the creation could take ~10 min), get the credentials to interact with your AKS cluster
az aks get-credentials -n $aks -g $rg
# Setup the phippyandfriends namespace, you will deploy later some apps into it
kubectl create namespace phippyandfriends
kubectl create clusterrolebinding default-view --clusterrole=view --serviceaccount=phippyandfriends:default

# 1. Assign acrpull role on our ACR to the AKS-generated service principal, the AKS cluster will then be able to pull images from our ACR
ACR_ID=$(az acr show -n $acr -g $rg --query id -o tsv)
echo $ACR_ID
az aks update -g $rg -n $aks --attach-acr $ACR_ID
# 2. Create a specific Service Principal for our Azure DevOps pipelines to be able to push and pull images and charts of our ACR
registryPassword=$(az ad sp create-for-rbac -n $acr-push --scopes $ACR_ID --role acrpush --query password -o tsv)
# Important note: you will need this registryPassword value later in this blog article in the Create a Build pipeline and Create a Release pipeline sections
echo $registryPassword
# 3. Create a specific Service Principal for our Azure DevOps pipelines to be able to deploy our application in our AKS
AKS_ID=$(az aks show -n $aks -g $rg --query id -o tsv)
aksSpPassword=$(az ad sp create-for-rbac -n $aks-deploy --scopes $AKS_ID --role "Azure Kubernetes Service Cluster User Role" --query password -o tsv)
# Important note: you will need this aksSpPassword value later in this blog article in the Create a Release pipeline section
echo $aksSpPassword

# 4. Retrieve registryLogin
az ad sp show --id http://$acr-push --query appId -o tsv
7a6a428a-1a03-4ccd-b832-68bbe610554b

ludovic@Azure:~$ echo $registryPassword
cdu~6gjP-SwWSdxBYY~RJCoUbSKng-IiRJ
ludovic@Azure:~$ AKS_ID=$(az aks show -n $aks -g $rg --query id -o tsv)
ludovic@Azure:~$ echo $AKS_ID
/subscriptions/92c69a02-47c5-4c5b-a49e-442d56f1ab8a/resourcegroups/k8s-lab/providers/Microsoft.ContainerService/managedClusters/k8s-staging
ludovic@Azure:~$ aksSpPassword=$(az ad sp create-for-rbac -n $aks-deploy --scopes $AKS_ID --role "Azure Kubernetes Service Cluster User Role" --query password -o tsv)
WARNING: Creating 'Azure Kubernetes Service Cluster User Role' role assignment under scope '/subscriptions/92c69a02-47c5-4c5b-a49e-442d56f1ab8a/resourcegroups/k8s-lab/providers/Microsoft.ContainerService/managedClusters/k8s-staging'
WARNING: The output includes credentials that you must protect. Be sure that you do not include these credentials in your code or check the credentials into your source control. For more information,see https://aka.ms/azadsp-cli
WARNING: 'name' property in the output is deprecated and will be removed in the future. Use 'appId' instead.
ludovic@Azure:~$ echo $aksSpPassword
F4Gj5pxc8Ijb~LvUFNLxpUuue8BLv..cg0
ludovic@Azure:~$



MUST DO :
Ouvrir dépo workshop pour toutes les instructions
Pull image Docker
Docker run
Logging sur Azure
Fork DevTeam1
Création ACR / AKS
Description du pipeline
Création du pipeline dans Azure DevOps
Configuration du pipeline
Run Azure pipeline
On a un chart Helm
Aller voir que les images Docker et le Chart Helm sont bien présent
(Création du namespace)
(Déploiement du chart Helm a la main)
Installation Flux sur Kubernetes
Pour staging :
Configuration Flux pour pointer vers le Helm (HelmRepo / HelmRelease)
Upgrade du chart pour déclenchement upgrade Chart Helm via Flux
Pour production :
Configuration Flux pour pointer vers le Helm (HelmRepo / HelmRelease)
Upgrade du chart pour déclenchement upgrade Chart Helm via Flux

NICE TO HAVE :
Le reste