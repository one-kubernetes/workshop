# GitOps, a slightly realistic situation on Kubernetes with FluxCD

<!-- TOC -->
- [👓 Abstract](#-abstract)
- [👓 Synopsis](#-synopsis)
- [✋ Pre-requisites](#-pre-requisites)
- [:warning: Flux v2 and Azure ACR](#warning-flux-v2-and-azure-acr)
- [🪃 You can send your feedback here!](#-you-can-send-your-feedback-here)
<!-- /TOC -->

Click the button below to start a new development environment:

[![Open in Gitpod](https://gitpod.io/button/open-in-gitpod.svg)](https://gitpod.io/#https://github.com/one-kubernetes/workshop)

## 👓 Abstract

You're tired of talks that deploy _hello-worlds_ to demonstrate the relevance of the _younameit_ tool.  
It's a good thing: what we're interested in is trying a slightly realistic _DevSecOps_ situation!  
We will therefore build a _step-by-step_ enterprise scenario with a _dev_ team, which deploys/updates/rolls back _WebApps_ on `Kubernetes` via `Helm` _charts_.
A second _dev_ team will use `Kustomize`, for the same purpose.  
And on the _Ops_ side, we will also be concerned with the platform's security issues: segregation of team rights, _WebApps_ network flows, transparent patch management on the technical stack, metrology, control of activities on the _cluster_.  
We will see how these teams collaborate with each other on a daily basis in a _GitOps_ workflow that relies on `Kubernetes`, `FluxCD`, `Azure DevOps`, and many other things…

## 👓 Synopsis

This is a _hands-on_ workshop, documented into this very same `Github` repository.  
We have 3 different people, **dev1**, **ops** and **dev2**.
Both devs build very simple Web apps that display Pokemon ID card. One Pokemon per app.  
Once the Web apps are developped, built and packaged, devs want to deploy them onto a `Kubernetes` _cluster_.  
The thing is… how to **smartly** deploy without relying on **ops**?

A first historical version of the workshop is performed on `Ms Azure` and every command is performed from a `Docker` container that is our work environment so nothing is required but:

- a browser
- and a `Google Cloud` account able to provision resources on `GKE`.
- or an `Azure` account able to provision resources on `Azure` (especially `AKS`).

First, we detail how to set-up this working environment within a `Docker` image.
How to build it and run it interactively.  

Second, we provision a `Kubernetes` _cluster_ in `AKS`.  
Then, we have a scenario on 3 tracks:

### 1st track - dev1

A **1st track** is a dev named **dev1** that builds a simple _Web application_ and **deploys it into his/her own `Kubernetes` _namespace_ with a simple `Kubernetes` `YAML` file**.  
The whole thing is to build the _CI/CD_ automation to perform these several steps…

![dev1](documentation/images/one-kubernetes_Sacha.png)

1. I developp a 1st _WebApp_ named [dev1-aspicot-app](https://github.com/one-kubernetes/dev1-aspicot-app)
1. By using [GitHub Actions](https://github.com/one-kubernetes/dev1-aspicot-app/actions) (👓 [Github Action code](https://github.com/one-kubernetes/dev1-aspicot-app/blob/main/.github/workflows/main.yaml))…
    * I package it as a `Docker` image (👓 [Dockerfile](https://github.com/one-kubernetes/dev1-aspicot-app/blob/main/Dockerfile))…
    * … and publish it into a _container registry_ (👓 [Docker Hub](https://hub.docker.com/r/thegaragebandofit/dev1-aspicot/tags))
1. Then I create the `YAML` file in order to deploy into `Kubernetes` as a _deployment_ and a _service_ (👓 [YAML file](https://github.com/one-kubernetes/dev1-aspicot-app/blob/main/deployment.yaml))
    * :twisted_rightwards_arrows: I have to ask **ops* in order for me to know which _namespace_ I have to use
1. :twisted_rightwards_arrows: Finally, I **ask **ops** for help** so that the `Kubernetes` _cluster_ take my deployment into account

packaging an `Helm` chart
1. publishing it into a _chart repository_
1. deploying it in a `Kubernetes` _namespace_
1. testing it
1. _promoting_ it for **Prod** deployment

### 2nd track - dev2

A **2nd track** is another dev that builds another _Web application_, but this time, he/she **is using a `Helm` _chart_ to deploy it into another dedicated `Kubernetes` _namespace_**.  

![dev2](documentation/images/one-kubernetes_Sigero.png)

1. I developp another _WebApp_ named [dev2-carapuce-app](https://github.com/one-kubernetes/dev2-carapuce-app)
1. By using [GitHub Actions](https://github.com/one-kubernetes/dev2-carapuce-app/actions) (👓 [Github Action code](https://github.com/one-kubernetes/dev2-carapuce-app/blob/main/.github/workflows/main.yaml))…
    * I package it as a `Docker` image (👓 [Dockerfile](https://github.com/one-kubernetes/dev2-carapuce-app/blob/main/Dockerfile))…
    * … and publish it into a _container registry_ (👓 [Docker Hub](https://hub.docker.com/r/thegaragebandofit/dev2-carapuce/tags))
1. In another [GitHub repository](https://github.com/one-kubernetes/dev2-helm-charts)…
    * I create the helm chart files (👓 [Helm chart files](https://github.com/one-kubernetes/dev2-helm-charts/tree/main/charts/dev2-carapuce))
    * I create the [GitHub Pages site](https://one-kubernetes.github.io/dev2-helm-charts/) where my `Helm` _charts_ will be published
    * I **release and publish** this `Helm` _chart_ as a release thanks to a [GitHub action](https://github.com/one-kubernetes/dev2-helm-charts/actions) (👓 [GitHub Action code](https://github.com/one-kubernetes/dev2-helm-charts/blob/main/.github/workflows/release.yaml))

### 3rd track - ops

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

1. To play the _codelab_, you may use an interactive workspace in [GitPod](https://www.gitpod.io) (it's free 💸). Just click the button [![Open in Gitpod](https://gitpod.io/button/open-in-gitpod.svg)](https://gitpod.io/#https://github.com/one-kubernetes/workshop).
1. To create a `Kubernetes` _cluster_ on **Azure**, [see instructions here](documentation/kubernetes-cluster-on-azure.md).
1. To create a `Kubernetes` _cluster_ on **Google Cloud GKE**, [see instructions here](documentation/kubernetes-cluster-on-gcloud.md).

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


## 🪃 You can send your feedback here!

[![roti.express SnowCamp 2022](documentation/images/SnowCamp2022_ROTIExpress_QRcode.png "roti.express SnowCamp 2022")](https://roti.express/r/sc22-031)
