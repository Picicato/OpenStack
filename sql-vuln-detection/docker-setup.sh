#!/bin/bash

# Build the Docker image for the vulnerable application
eval $(minikube docker-env)
docker build -t vuln-app:latest ./vuln-app
docker build -t sqli-detector:latest ./sqli-detector