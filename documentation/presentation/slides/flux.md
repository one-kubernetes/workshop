# Flux

----

## Qu'est-ce que c'est ?

* `Flux` est un outil qui permet de faire du _GitOps_ sur `Kubernetes`
* Il scrute des sources qui vont servir à injecter des descriptions de ressources dans `Kubernetes`

----

## La CLI

* une CLI permet :
  1. de créer les fichiers `YAML` pour déployer les ressources `Kubernetes` que l'on souhaite
     * y compris les propres composants `Flux`
  1. d'interagir avec le dépôt `git` qui va servir de configuration `Flux`
  1. d'interroger l'état de Flux sur le _cluster_
     * logs des _operators_
     * _CRD_

----

<img class="r-stretch" src="../images/flux_schema.png">

----

## Les composants

* `source controller` pour scruter les sources de configuration depuis des dépôts `git`
* `helm controller` pour détecter de nouvelles _releases_ depuis des dépôts de _charts_ `Helm`
* des _CRD_, qui servent de machine à état pour stocker la configuration dans le _cluster_

----

## Flux s'appuie sur Kustomize

* `kustomize controller` qui passe la configuration trouvée à `Kustomize`
    1. `Kustomize` consolide la configuration trouvée
    2. et hydrate les sections template présentes dans la configuration

----

* À partir de là, toute la configuration du _cluster_ Kubernetes peut se faire exclusivement en manipulant des dépôts `git`.
* On est dans le respect du _pattern_ roi dans `Kubernetes` : **la convergence vers un état cible décrit**

----
