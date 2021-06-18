# GitOps, a slightly realistic situation on Kubernetes with FluxCD

<!-- TOC -->
- [Abstract](#abstract)
- [Synopsis](#synopsis)
<!-- /TOC -->

## Abstract

You're tired of talks that deploy _hello-worlds_ to demonstrate the relevance of the _younameit_ tool.  
It's a good thing: what we're interested in is trying a slightly realistic _DevSecOps_ situation!  
We will therefore build a _step-by-step_ enterprise scenario with a _dev_ team, which deploys/updates/rolls back _WebApps_ on `Kubernetes` via `Helm` _charts_.
A second _dev_ team will use `Kustomize`, for the same purpose.  
And on the _Ops_ side, we will also be concerned with the platform's security issues: segregation of team rights, _WebApps_ network flows, transparent patch management on the technical stack, metrology, control of activities on the _cluster_.  
We will see how these teams collaborate with each other on a daily basis in a _GitOps_ workflow that relies on `Kubernetes`, `FluxCD`, `Azure DevOps`, and many other things…

## Synopsis

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

``` mermaid
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

# Why 3 tracks?

What I mean by "3 tracks" is that we'll be able to do the following:

- demonstrate each track one after the other
- let attendees choose one track or another, practice on it
- let attendees team up to synchronize with each others in order to complete the whole 3 tracks.


Hope you will enjoy this workshop!🙂