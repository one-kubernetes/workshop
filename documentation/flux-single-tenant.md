# Flux - singtle tenant

## First install

First of all, you can check that your `Flux` _CLI_ is able to communicate with your `Kubernetes` _cluster_.

```bash
flux check --pre
```

Now you will perform the initial configuration of `Flux`.  
To do so, you must generate a `Github` _token_ so that `Flux` is able to interact with your repository.

```bash
export GITHUB_TOKEN="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"
export GITHUB_USER="one-kubernetes"
export GITHUB_REPO="flat"

flux bootstrap github --context=k8s-staging --owner=${GITHUB_USER} --repository=${GITHUB_REPO} --personal --branch=main --path=clusters/staging
```

By doing so, `Flux`:
- create a Github source that will be its configuration reference.
- deploy all the kubernetes resources that it needs to run (namespace, operator, CRDs…)

You can check what sources `Flux` monitor.

```bash
flux get all
```

## Configuration

Now you have to upgrade `Flux` configuration so that it watches 2 extra sources: the charts your `Azure DevOps` _pipeline_ publishes for your _dev_ team.

```bash
flux create helmrelease front --chart front --source HelmRepository/app --namespace default
flux create helmrelease back --chart back --source HelmRepository/app --namespace default
flux create source helm app --url http://20.93.169.137:8080 --namespace default
```

