# Create a deployment and service on cluster

```bash
kubectl create ns test
kubectl -n test create deployment web --image=nginx:1.18 --port=80
kubectl -n test expose deployment/web --port=80 --target-port=80 --type=NodePort
kubectl -n test  port-forward svc/web 8080:80

# Verify webserver running 
curl  http://localhost:8080
```