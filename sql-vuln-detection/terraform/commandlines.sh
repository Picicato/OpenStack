#!/bin/bash

# Build the Docker image for the vulnerable application
eval $(minikube docker-env)
docker build -t vuln-app:latest .

# Port-forwarding for the vulnerable app and Postgres database
minikube kubectl -- -n sqli-lab port-forward svc/vuln-app 5000:80 &
minikube kubectl -- -n sqli-lab port-forward svc/postgres 5432:5432 &

# To access the Postgres database from within the cluster
minikube kubectl -- exec -n sqli-lab -it deploy/postgres -- psql -U test -d test
# Then run:
\dt
SELECT * FROM users;