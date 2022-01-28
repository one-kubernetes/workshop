# GitOps, a slightly realistic situation on Kubernetes with FluxCD

<!-- TOC -->
- [👓 Abstract](#-abstract)
- [👓 Synopsis](#-synopsis)
- [👉 Let-su go!](#-let-su-go)
- [👉 Enter your work environment](#-enter-your-work-environment)
- [👉 Connect onto Azure](#-connect-onto-azure)
- [👉 Provision a Kubernetes cluster and a Container/Chart Registry](#-provision-a-kubernetes-cluster-and-a-containerchart-registry)
<!-- /TOC -->

Click the button below to start a new development environment:

[![Open in Gitpod](https://gitpod.io/button/open-in-gitpod.svg)](https://gitpod.io/#https://github.com/one-kubernetes/workshop/tree/lpiot/snowcamp2022)

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

![sequence diagram](documentation/mermaid-diagram-20210618090905.svg)

```mermaid
sequenceDiagram
    participant d1 as Dev1
    participant d2 as Dev2
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


## ✋ Pre-requisites

1. To play the codelab, you may use an interactive workspace based on a Docker image. [See instructions, here](./codelab-docker-image/README.md).
1. To create a `Kubernetes` _cluster_ on **Azure**, [see instructions here](documentation/kubernetes-cluster-on-azure.md).

# 🚪 Namespace isolation

💡 First of all, you want to isolate both _dev_ teams in their own _namespace_.

🧙‍♂️ As the _Ops_ team.  
You want to create 2 _namespaces_ for both your 🙋‍♀️_dev1_ team and your 🙋‍♂️_dev2_ team.  
* 🙋‍♀️_dev1_ team should be able to use its _namespace_ but not the one of 🙋‍♂️_dev2_ team.
* 🙋‍♂️_dev2_ team should be able to use its _namespace_ but not the one of 🙋‍♀️_dev1_ team.
* 🧙‍♂️_ops_ team should be able to use both, since it is the admin of the `kubernetes` _cluster_.

To do so, you have to run the following commands…

```bash
# Create resources (namespaces, service accounts, roles and role bindings)
kubectl create -f access.yml

# how to get secrets
kubectl describe sa dev1 -n dev1-ns
kubectl describe sa dev2 -n dev2-ns

# how to get service account token
kubectl get secret dev1-token-5bx7g --namespace=dev1-ns -o "jsonpath={.data.token}" | base64 --decode
kubectl get secret dev2-token-jhvnf --namespace=dev2-ns -o "jsonpath={.data.token}" | base64 --decode

# how to get service account client certificate key
kubectl get secret dev1-token-5bx7g --namespace=dev1-ns -o "jsonpath={.data['ca\.crt']}"
kubectl get secret dev2-token-jhvnf --namespace=dev2-ns -o "jsonpath={.data['ca\.crt']}"

# how to create a pod
export KUBECONFIG=./mykube-config.yml
kubectl config current-context
kubectl run nginx --image=nginx --restart=Never --namespace=dev1-ns
kubectl run nginx --image=nginx --restart=Never --namespace=dev2-ns

kubectl auth can-i --namespace=dev3 --list
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

🧙‍♂️ Now you are the _Ops_ team.  
What you have to do is install and configure flux so that **every time a new chart is published**, it is deployed into the right namespace on the right `kubernetes`_cluster_.


# Flux

To install and configure `Flux` in order to manage deployment onto your `Kubernetes` _cluster_ as a **single _tenant_**, see [here](documentation/flux-single-tenant.md).  
To do so in order for your `Flux` to be able to manage **multiple _tenants_** onto your `Kubernetes` _cluster_, see [here](documentation/flux-multi-tenant.md).

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
