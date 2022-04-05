# How to create the needed kubernetes resources on Azure?

To play this lab, you need to:

* have a `Kubernetes` _cluster_ available (here are the instructions to create one on **Azure**)
* have a _container registry_ (here are the instructions to create one on **Azure** ACR)

## 👉 Connect onto Azure

First of all, you have to connect onto your `Azure` account…

```bash
az login
```

Follow the instructions.

## 👉 Provision a Kubernetes cluster

```bash
export location='eastus'
export rg='k8s-lab'
export aks='myk8scluster'
export acr='k8sLabRegistry'

# Create a resource group $rg on a specific location $location (for example eastus) which will contain the Azure services we need 
az group create -l $location -n $rg

# Setup of the AKS cluster
latestK8sVersion=$(az aks get-versions -l $location --query 'orchestrators[-1].orchestratorVersion' -o tsv)
echo $latestK8sVersion
az aks create -l $location --name $aks -g $rg --generate-ssh-keys -k $latestK8sVersion --node-count 1

# Once created (the creation could take ~10 min), get the kube configuration to interact with your AKS cluster
az aks get-credentials --name $aks -g $rg
kubectl get nodes
```

## 👉 Provision a Container Registry / Chart Repository

We'll use an `Azure` _container registry_ that is also an `Helm` _charts_ repository.  

`Azure DevOps` _pipeline_ will have to use the credentials in order to interact with it.
But our `Kubernetes` _cluster_ is able to interact thanks to a dedicated service principal (`IAM`).

```bash
# Create an ACR registry $acr
az acr create -n $acr -g $rg -l $location --sku Basic

# 1. Assign acr pull role on our ACR to the AKS-generated service principal, the AKS cluster will then be able to pull images from our ACR
ACR_ID=$(az acr show -n $acr -g $rg --query id -o tsv)
echo $ACR_ID
az aks update -g $rg -n $aks --attach-acr $ACR_ID

# 2. Create a specific Service Principal for our Azure DevOps pipelines to be able to push and pull images and charts of our ACR
registryPassword=$(az ad sp create-for-rbac -n $acr-push --scopes $ACR_ID --role acrpush --query password -o tsv)
echo "registryPassword=${registryPassword}"

# 3. Create a specific Service Principal for our Azure DevOps pipelines to be able to deploy our application in our AKS
AKS_ID=$(az aks show -n $aks -g $rg --query id -o tsv)
aksSpPassword=$(az ad sp create-for-rbac -n $aks-deploy --scopes $AKS_ID --role "Azure Kubernetes Service Cluster User Role" --query password -o tsv)

# Important note: you will need this aksSpPassword value later in this blog article in the Create a Release pipeline section
echo $aksSpPassword

# 4. Retrieve registryLogin
registryLogin=$(az ad sp list --display-name $acr-push --query [0].appId -o tsv)
echo "registryLogin=${registryLogin}"

# ⚠ Important note: you will need these 3 values later in the lab to create Azure Devops pipelines
echo "registryName=${acr}"
echo "registryLogin=${registryLogin}"
echo "registryPassword=${registryPassword}"

```
