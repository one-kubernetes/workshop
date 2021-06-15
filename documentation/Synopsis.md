# Workshop agenda

This is a hands-on workshop, performed on `Ms Azure` and documented (yet to come) in a `Github` repository.  
Every command is performed in `Azure Cloud Shell` so nothing is required but a browser and an account able to provision resources on `Azure`.  
First, we detail how to set-up a working environment within a `Docker` image. How to build it and run it interactively.  
Second, we provision a `Kubernetes` _cluster_ (`K3S` or `AKS`, we'll see what is the easiest option for the whole workshop steps).  
Then, we have a scenario on 3 tracks:

A **1st track** is a dev that builds a simple application displaying a _Pokemon_ identity card (let's say _Bulbasaur_).

1. first version of the app, it's a read-only static Web page
2. next, the app relies on a database to retrieve the info
3. then, the app has multiple endpoints that route to several evolution of this _Pokemon_ (_Bulbasaur_, _Ivysaur_ and _Venusaur_).
4. at last, the app embed CRUD capabilities.

The whole thing is to build the _CI/CD_ automation to perform these several steps in term of:

- building the app
- packaging it as a `Docker` image
- deploying it in a `Kubernetes` _namespace_
- testing it
- promoting it for **Prod** deployment

A **2nd track** is another dev performing the same steps but with another pokemon and deploying in another `Kubernetes` _namespace_.  

A **3rd track** is a _platform ops_ that operates the `Kubernetes` _cluster_.

- He has to upgrade the _cluster_
- upgrade the database engine,
- manage the monitoring and alerting systems in order to run the **Prod** smoothly.

By doing so, we will be able to show how different teams may work together onto the same `Kubernetes` _cluster_ and the amount of coordination that is needed (or not).

All the automation relies on `Azure DevOps` and `FluxCD v2`.

# Why 3 tracks?

What I mean by "3 tracks" is that we'll be able to do the following:

- demonstrate each track one after the other
- let attendees choose one track or another, practice on it
- let attendees team up to synchronize with each others in order to complete the whole 3 tracks.


Hope this answers your questions🙂