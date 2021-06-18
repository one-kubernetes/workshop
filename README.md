# workshop
The main project for this workshop.

# Synopsis

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