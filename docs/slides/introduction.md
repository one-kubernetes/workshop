# GitOps

Une mise en situation un peu réaliste<br>sur Kubernetes avec Flux  

----

# Synopsis

T’en as assez des _talks_ qui déploient des _hello-world_ pour démontrer la pertinence de l’outil *younameit*.  
Ça tombe bien : ce qui nous intéresse, c’est plutôt d’essayer une mise en situation **DevSecOps** un peu réaliste.  
On va donc construire pas à pas un scénario d’entreprise  avec des _dev teams_, qui _deploy / update / rollback_ des _WebApps_ Pokemon sur `Kubernetes`. Elles utilisent `Kustomize` ou des charts `Helm` pour cela.  
Côté _Ops_, on va aussi se préoccuper des enjeux de sécurité de la plateforme : ségrégations des droits des équipes, des flux réseau des _WebApps_. Pour cela, nos _Ops_ vont utiliser `Kyverno`. Et puis des applis, ça se _monitor_, _patch management_ transparent sur la stack technique, métrologie, contrôle des activités sur le _cluster_.  
On va voir comment ces équipes **collaborent** entre elles au quotidien dans un _workflow_ **GitOps** qui s’appuie sur `Kubernetes` et `Flux`, autour d'un code stocké dans `Github`,  et plein d’autres choses encore…
<!-- .element class="r-fit-text" align="justify" -->

----

## Laurent Grangeau

Solution architect @ Google  
[@laurentgrangeau](https://twitter.com/laurentgrangeau/) on Twitter  
<img class="r-stretch" src="images/laurentgrangeau.jpg">

----

## Ludovic Piot
DevOps & Cloud architect Freelance  
[@lpiot](https://twitter.com/lpiot/) on Twitter  
<img class="r-stretch" src="images/lpiot.jpg">

----

# Pour suivre…

1. les dépôts sont dans `Github` :<br>https://github.com/one-kubernetes
1. le dépôt principal :<br>https://github.com/one-kubernetes/workshop
1. le présent [_slidedeck_](https://github.com/one-kubernetes/workshop/blob/main/slidedecks/slidedeck-fr.html) en 🇫🇷
2. les [instructions du _workshop_](https://github.com/one-kubernetes/workshop/blob/main/documentation/flux-multi-tenant.md)

----

# Envoyez vos feedbacks

https://roti.express/r/gitops-20220405
<img class="r-stretch" src="https://roti.express/img/roti-magnet.png">
