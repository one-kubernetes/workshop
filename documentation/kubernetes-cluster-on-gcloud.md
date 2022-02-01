# How to create the needed kubernetes resources on Google Cloud?

To play this lab, you need to:

* have a `Kubernetes` _cluster_ available (here are the instructions to create one on **Google Cloud GKE**)

## 👉 Connect onto Google Cloud with the gcloud sdk

First of all, you have to connect onto your `Google Cloud` account…

```bash
gcloud auth login
```

Follow the instructions.

## 👉 Create a Google Cloud project

#TODO: instructions needed here
```bash
gcloud projects create snowcamp2022-gitops-flux
```

## 👉 Provision a Kubernetes cluster

```bash
export region='europe-west1-b'
export name='k8s-staging'

# Setup of the GKE cluster
gcloud container clusters create --region='europe-west1-b' 'k8s-staging'

# Once created (the creation could take ~5 min), get the kube configuration to interact with your GKE cluster
kubectl get nodes
```
