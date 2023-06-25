## Kubernetes

K8s is a container orchestration system that allows to manage containers clusters.
It uses etcd for managing cluster state.

Minikube is an application that helps to manage a local k8s cluster

```shell
brew install minikube
```

Start minikube cluster (this will download k8s)

```shell
minikube start
```

Open k8s dashboard in a browser

```shell
minikube dashboard
```

Build test application image

```shell
docker build -t my-golang-app .
```

Run test application via docker

```shell
docker run -it -p 8081:8081 my-golang-app
```

View k8s nodes in the cluster

```shell
kubectl get nodes
```

Use minikube docker instead of the local docker

```shell
eval $(minikube docker-env)
```

Build test application image for minikube docker

```shell
docker build -t my-golang-app .
```

Create k8s deployment

```shell
kubectl apply -f sog-golang-deployment.yaml
```

Deployments tell k8s how to create and update instances of application.

List all deployments

```shell
kubectl get deployments
```

Delete deployment

```shell
kubectl delete deployment xxx
```

By default pods are not accessible from the outside.
Expose deployment to the internet

```shell
kubectl expose deployment my-golang-app --type=LoadBalancer --port=8081
```

Lookup port from which deployment is available (it will not be 8081)
from the localhost

```shell
kubectl get services
```

Add metrics addon

```shell
minikube addons enable metrics-server
```

Pod is a k8s abstraction: a group of containers that share
ip address, port space, and volumes.

View pods

```shell
kubectl get pods
```

Pod runs on a node. Node is a working machine in k8s cluster.
Node can have multiple pods.

View pod logs.

```shell
kubectl logs $(kubectl get pods | awk 'NR == 2 {print $1}') 
```

Run bash inside the container

```shell
kubectl exec -ti $(kubectl get pods | awk 'NR == 2 {print $1}') -- bash
```

When inside the container you can access your app via

```shell
curl localhost:8081/ping
```

Service encapsulates a logical set of pods.

Delete existing service with the --type=LoadBalancer.
Expose service to an external traffic.
Difference between --type=NodePort and --type=LoadBalancer is unclear

```shell
kubectl delete services my-golang-app
kubectl expose deployment my-golang-app --type=NodePort --port=8081
```

We need `minikube service ...` to access our service via
localhost.

```shell
minikube service my-golang-app
```

View ReplicaSets of deployments.
DESIRED is the desired number of app replicas
CURRENT is the, ahem, current number of app replicas

```shell
kubectl get rs
```

Scale deployment to 4 replicas. Now `kubectl get rs` will show
DESIRE=CURRENT=4.

```shell
kubectl scale deployments/my-golang-app --replicas=4
```

Build a new version of the app

```shell
docker build -t my-golang-app-v2 -f v2.Dockerfile .
```

Change deployment image, this will do the rolling update

```shell
kubectl set image deployments/my-golang-app my-golang-app=my-golang-app-v2
```

We can change the image back, this will do the rolling update back.

```shell
kubectl set image deployments/my-golang-app my-golang-app=my-golang-app
```
