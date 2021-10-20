# How to prepare your workspace as a Docker interactive container?

## Description

We built a `Docker` image named [thegaragebandofit/infra-as-code-tools:one-kubernetes](https://hub.docker.com/layers/172662032/thegaragebandofit/infra-as-code-tools/one-kubernetes/images/sha256-95723c5c9a016ec083c16fd596aab981ecf7e3c6bad797d3823e3e2647c8b3cb?context=repo) that contains:

- git, vim, jq, yq, tmux and other common tools
- azure cli
- kubectl
- helm
- kustomize
- flux

So you have everything you need 🧳 in this image 🐋!

## 👉 How to work into your work environment?

```bash
cd ${myLocalGitRepositoryClone}
docker container run -it --volume $(pwd):/mycode --name gitops-lab thegaragebandofit/infra-as-code-tools:one-kubernetes
```

Now you're in the container, with all the tools that are needed.  
The `/mycode` directory is dedicated to your code.

## How to build the Docker image?

💡 If you wan't to know this `docker` image is built and what tools it contains…

```bash
docker image pull thegaragebandofit/infra-as-code-tools:one-kubernetes
docker image history --no-trunc thegaragebandofit/infra-as-code-tools:one-kubernetes
```

You can also look at the content of the [`Dockerfile`](./Dockerfile).

💡 To build it…

```bash
cd ${myLocalGitRepositoryClone}/codelab-docker-image/
docker image build --tag mylab:1.0 .
```
