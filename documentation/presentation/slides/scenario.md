# Le scénario…

----

## 2 équipes de dev

* 2 équipes *dev1* et *dev2* conçoivent chacune une application _Pokemon_.
* un _Pokemon_ par application.

----

#### dev1

<img class="r-stretch" src="../images/dev1_website001.png">

----

#### dev2

<img class="r-stretch" src="../images/dev2_website001.png">

----

## L'application Pokemon ID

* L'application est un site _Web_ statique affichant la fiche _PokeDex_ d'un _Pokemon_.  
* Chaque équipe dispose de son ou ses dépôts `Github` (un par app).

----

#### dev1 - Aspicot

https://github.com/one-kubernetes/dev1-aspicot-app

<img class="r-stretch" src="../images/dev1_files.png">

----

#### dev2 - Carapuce

https://github.com/one-kubernetes/dev2-carapuce-app

<img class="r-stretch" src="../images/dev2_files.png">

----

## Le code de l'application Pokemon ID

----

Une simple page `html` affichant la page _PokeDex_ d'un _Pokemon_ …  

#### app/index.html

```html [6|9-10]
<!doctype html>
<html lang=en>
(…)
<body>
(…)
	<img src="https://assets.pokemon.com/assets/cms2/img/pokedex/full/013.png">
(…)
	<div class="message">
		<h1>Aspicot #013</h1>
		<div class="congrats">L'aiguillon sur son front est très pointu.(…)</div>
	</div>
(…)
</html>
```

----

… incluse dans une image `Docker` embarquant un Web server `NGinx`.

#### Dockerfile

```docker [1-2]
FROM nginx:1.21.3-alpine
ADD app/index.html /usr/share/nginx/html
```

----

### Des évolutions dans l'application Pokemon ID

L'équipe **dev2** va vouloir faire des mises à jour sur son application.

----

<img class="r-stretch" src="../images/dev2_website001.png">

----

<img class="r-stretch" src="../images/dev2_website002.png">

----

<img class="r-stretch" src="../images/dev2_website003.png">

---

## Où déployer ?

* L'équipe *ops* dispose d'un _cluster_ `Kubernetes` sur lequel les applications _Pokemon_ seront déployées.
  * une partie de son _cluster_ à des fins de **test** : `staging`
  * Plus tard, une autre partie du _cluster_ sera dédiée à la **prod** : `prod`
* Pour chacune des équipes **dev1** et **dev2**, on met à disposition un _namespace_ dédié et **isolé** du reste du _cluster_.

---

### Comment déployer ?

* La cible de déploiement est un _namespace_ dédié sur le _cluster_ `Kubernetes` de l'entreprise.
* L'équipe **dev1** produit le fichier `YAML` qui va construire les ressources `Kubernetes` nécessaires au déploiement de son application.

----

#### deployment.yaml

```YAML [2|4-5|9|18-22|25|27-28|31|33-35]
apiVersion: apps/v1
kind: Deployment
metadata:
  name: dev1-aspicot
  namespace: dev1-ns
  labels:
    app: dev1-aspicot
spec:
  replicas: 1
  selector:
    matchLabels:
      app: dev1-aspicot
  template:
    metadata:
      labels:
        app: dev1-aspicot
    spec:
      containers:
      - name: dev1-aspicot
        image: thegaragebandofit/dev1-aspicot:1.0
        ports:
        - containerPort: 80
---
apiVersion: v1
kind: Service
metadata:
  name: dev1-aspicot-service
  namespace: dev1-ns
spec:
  selector:
    app: dev1-aspicot
  ports:
  - name: http
    protocol: TCP
    port: 80
    targetPort: 80
  type: LoadBalancer
```

----

Ensuite, **dev1** aura à pousser son fichier `YAML` via une commande

```bash
$ kubectl create -f deployment.yaml
```

1. ⚠️ Ça nécessite de disposer d'un accès réseau au _cluster_
2. ⚠️ Ça nécessite de disposer d'un compte pour accéder au _cluster_.
3. 🔓 Si on automatise (_pipeline CI/CD_, par exemple), ça nécessite de mettre ses accès à la disposition de l'automate 😕

----

💡 C'est là que GitOps entre en scène ! 🍾