#!/bin/bash

# Build the Docker images
eval $(minikube docker-env)
docker build -t vuln-app:latest .
docker build -t sqli-detector:latest .

# Port-forwarding for the vulnerable app and Postgres database
minikube kubectl -- -n sqli-lab port-forward svc/vuln-app 5000:80 &
minikube kubectl -- -n sqli-lab port-forward svc/postgres 5432:5432 &
minikube kubectl -- -n sqli-lab port-forward svc/sqli-detector 8000:8000 &

# To access the Postgres database from within the cluster
minikube kubectl -- exec -n sqli-lab -it deploy/postgres -- psql -U test -d test
# Then run:
\dt
SELECT * FROM users;

# Clean up existing SQLi detector deployment
minikube kubectl -- delete deployment sqli-detector -n sqli-lab
minikube kubectl -- delete service sqli-detector -n sqli-lab

# Deploy the SQLi detector module
terraform apply -target=module.sqli_detector -auto-approve

# Test the SQLi detector by sending a payload
curl -X POST http://localhost:8000/log -d '{"payload": "DROP"}' -H "Content-Type: application/json"