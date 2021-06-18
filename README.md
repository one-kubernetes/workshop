# GitOps, a slightly realistic situation on Kubernetes with FluxCD

<!-- TOC -->
- [👓 Abstract](#-abstract)
- [👓 Synopsis](#-synopsis)
- [👉 Let-su go!](#-let-su-go)
- [👉 Enter your work environment](#-enter-your-work-environment)
- [👉 Connect onto Azure](#-connect-onto-azure)
- [👉 Provision a Kubernetes cluster and a Container/Chart Registry](#-provision-a-kubernetes-cluster-and-a-containerchart-registry)
<!-- /TOC -->

## 👓 Abstract

You're tired of talks that deploy _hello-worlds_ to demonstrate the relevance of the _younameit_ tool.  
It's a good thing: what we're interested in is trying a slightly realistic _DevSecOps_ situation!  
We will therefore build a _step-by-step_ enterprise scenario with a _dev_ team, which deploys/updates/rolls back _WebApps_ on `Kubernetes` via `Helm` _charts_.
A second _dev_ team will use `Kustomize`, for the same purpose.  
And on the _Ops_ side, we will also be concerned with the platform's security issues: segregation of team rights, _WebApps_ network flows, transparent patch management on the technical stack, metrology, control of activities on the _cluster_.  
We will see how these teams collaborate with each other on a daily basis in a _GitOps_ workflow that relies on `Kubernetes`, `FluxCD`, `Azure DevOps`, and many other things…

## 👓 Synopsis

This is a hands-on workshop, performed on `Ms Azure` and documented into this very same `Github` repository.    
Every command is performed from a Docker container that is our work environement so nothing is required but:

- a browser
- a docker runtime (Docker-Desktop)
- and an `Azure` account able to provision resources on `Azure`.

First, we detail how to set-up this working environment within a `Docker` image.
How to build it and run it interactively.  

Second, we provision a `Kubernetes` _cluster_ in `AKS`.  
Then, we have a scenario on 3 tracks:

Here is a sequence diagram of what we will do:

![sequence diagram](documentation\mermaid-diagram-20210618090905.svg)

```mermaid
sequenceDiagram
    participant d1 as Dev 1
    participant d2 as Dev 2
    participant git as Github
    participant azd as Azure DevOps
    participant acr as ACR (container registry)
    participant acrh as ACR (helm charts repository)
    participant k8sd1 as k8s namespace Dev 1
    participant k8sd2 as k8s namespace Dev 2
    participant fcrd as Flux CRDs
    participant fope as Flux operator
    participant o1 as Ops 1

    d1->>git: push App1_v1 @main
    Activate azd
    azd-->>git: trigger CI-pipeline
    azd->>acr: push Docker image of App_v1
    azd->>acrh: push Helm Chart of App_v1
    Deactivate azd
    o1-)fcrd: Define Source Helm Charts Repository for App_v1
    Activate fcrd
    fope-->>fcrd: Get reconciliation config.    
    fope--)acrh: source Helm repo to detect any new version of Helm Chart
    fope->>k8sd1: upgrade Helm Release to deploy new version of Helm Chart
    Deactivate fcrd

    d2->>git: push App2_v1 @main
    Activate azd
    azd-->>git: trigger CI-pipeline
    azd->>acr: push Docker image of App_v1
    azd->>acrh: push Helm Chart of App_v1
    Deactivate azd
    o1-)fcrd: Define Source Helm Charts Repository for App_v2
    Activate fcrd
    fope-->>fcrd: Get reconciliation config.    
    fope--)acrh: source Helm repo to detect any new version of Helm Chart
    fope->>k8sd2: upgrade Helm Release to deploy new version of Helm Chart
    Deactivate fcrd
```

A **1st track** is a dev that builds a simple application.

The whole thing is to build the _CI/CD_ automation to perform these several steps in term of:

- building the app
- packaging it as a `Docker` image
- publishing it into a _container registry_
- packaging an `Helm` chart
- publishing it into a _chart repository_
- deploying it in a `Kubernetes` _namespace_
- testing it
- _promoting_ it for **Prod** deployment

A **2nd track** is another dev performing the same steps but with another application and deploying it into another `Kubernetes` _namespace_.  

A **3rd track** is a _platform ops_ that operates the `Kubernetes` _cluster_.

- How he manages the _Flux_ configuration and orchestration
- He has to upgrade the the database engine, _(yet to come)_
- to upgrade the _cluster_, _(yet to come)_
- to manage the monitoring and alerting systems in order to run the **Prod** smoothly. _(yet to come)_

By doing so, we will be able to show how different teams may work together onto the same `Kubernetes` _clusters_ and the amount of coordination that is needed (or not).

All the automation relies on `Azure DevOps` and `Flux v2`.

**Why 3 tracks?**

What I mean by "3 tracks" is that we'll be able to do the following:

- demonstrate each track one after the other
- let attendees choose one track or another, practice on it
- let attendees team up to synchronize with each others in order to complete the whole 3 tracks.


Hope you will enjoy this workshop!🙂

# 👉 Let-su go!

Here are the steps to perform…

👉 Fork this `git` repository: https://github.com/one-kubernetes/workshop.  
👉 And clone it locally.

Now you have all the instructions at hand!

## 👉 Enter your work environment

We built a [`docker` image](https://hub.docker.com/layers/thegaragebandofit/infra-as-code-tools/azure-full/images/sha256-540102deff40659a44ef1c1a8372b1c587b1140f70222fdf05c52c101f9216e8?context=repo) that contains:

- git, vim, jq, yq, tmux and other common tools
- azure cli
- kubectl
- helm
- kustomize
- flux

So you have everything you need 🧳 in this image 🐋!

```bash
cd ${myLocalGitRepositoryClone}
docker container run -it --volume $(pwd):/mycode --name gitops-lab thegaragebandofit/infra-as-code-tools:azure-full
```

Now you're in the container, with all the tools that are needed.

💡 If you wan't to know this `docker` image is built and what tools it contains…

```bash
docker image history --no-trunc thegaragebandofit/infra-as-code-tools:azure-full
```

💡 To build it…

```bash
cd ${myLocalGitRepositoryClone}/docker
docker image build --tag mylab:1.0 .
```

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
export aks='k8s-staging'
export acr='CloudOuestK8sLabRegistry'

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
```

# Dev Team

Now you are the _dev_ team.  
You have to build a CI pipeline that will build, package and ship you application so that it can be deployed onto a `Kubernetes` _cluster_.  

👉 Fork this `git` repository: https://github.com/one-kubernetes/dev-team1.  
👉 And clone it locally.

Now, follow the live-demo:

- enter into Azure DevOps
- create a project
- create a _pipeline_ for your _frontend_ app 
    - link it to your Github repository
    - configure it from the [ci-pipeline.yml](https://github.com/one-kubernetes/dev-team1/blob/main/front/ci-pipeline.yml) file
    - add the 3 variables that are needed
        - registryName
        - registryLogin
        - registryPassword
- create a _pipeline_ for your _backend_ app from the [ci-pipeline.yml](https://github.com/one-kubernetes/dev-team1/blob/main/back/ci-pipeline.yml) file

You can run them manually and see every step running.  
Now you may have a look to your ACR and check that you have a docker image and an helm chart that are published.

You may upgrade your application and see that the CI is working fine: for every push, the pipeline will
- build the app,
- package it into a `docker` image
- and publish both the `docker`image and the `helm`_chart_

# Ops Team

Now you are the _Ops_ team.  
What you have to do is install and configure flux so that **every time a new chart is published**, it is deployed into the right namespace on the right `kubernetes`_cluster_.

## Flux install

First of all, you can check that your `Flux` _CLI_ is able to communicate with your `Kubernetes` _cluster_.

```bash
flux check --pre
```

Now you will perform the initial configuration of `Flux`.  
To do so, you must generate a `Github` _token_ so that `Flux` is able to interact with your repository.

```bash
export GITHUB_TOKEN="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"
export GITHUB_USER="one-kubernetes"
export GITHUB_REPO="workshop"

flux bootstrap github --context=k8s-staging --owner=${GITHUB_USER} --repository=${GITHUB_REPO} --personal --branch=main --path=clusters/staging
```

By doing so, `Flux`:
- create a Github source that will be its configuration reference.
- deploy all the kubernetes resources that it needs to run (namespace, operator, CRDs…)

You can check what sources `Flux` monitor.

```bash
flux get all
```

## Flux configuration

Now you have to upgrade `Flux` configuration so that it watches 2 extra sources: the charts your `Azure DevOps` _pipeline_ publishes for your _dev_ team.

```bash
flux create helmrelease front --chart front --source HelmRepository/app --namespace default
flux create helmrelease back --chart back --source HelmRepository/app --namespace default
flux create source helm app --url http://20.93.169.137:8080 --namespace default
```

## :warning: Flux v2 and Azure ACR

`Azure ACR` is migrating to **OCI** _container registry_ standard.  
This standard is only available in experimental mode in `Helm`.  
And Flux v2 is _as of now_ **not compatible** with this standard.  
So you have to use another _chart repository_ than `ACR`.

You can deploy a [Chart Museum](https://github.com/helm/chartmuseum) by following [these instructions](https://github.com/helm/chartmuseum#installing-charts-into-kubernetes) (thanks to `helm`!).  
And you can push your freshly built chart into this repository by performing this command:

```bash
curl --data-binary "@$(projectName)-$(helmChartVersion).tgz"  http://20.93.169.137:8080/api/charts
```

# 🔎 References

This workshop is inspired by the following Internet resources:

- Azure DevOps pipeline: https://cloudblogs.microsoft.com/opensource/2018/11/27/tutorial-azure-devops-setup-cicd-pipeline-kubernetes-docker-helm/
- Flux v2 simple demo: https://github.com/fluxcd/flux2-kustomize-helm-example
- Flux v2 multi-tenancy: https://github.com/fluxcd/flux2-multi-tenancy
