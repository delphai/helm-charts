#! /usr/bin/env bash
set -e
kubectx delphai-staging

RELEASE_NAME=query-resolution

REPO_NAME=query-resolution

IMAGE=delphaistaging.azurecr.io/query-resolution@sha256:da99cb425632a4f7eca5b1f3dcd8e131f165aa476d76e2358749b57184ac6555

kubectl create namespace ${REPO_NAME} --output yaml --dry-run=client | kubectl apply -f -
kubectl patch serviceaccount default --namespace ${REPO_NAME} -p "{\"imagePullSecrets\": [{\"name\": \"acr-credentials\"}]}"
DOMAIN=$(kubectl get secret domain -o json --namespace default | jq .data.domain -r | base64 -d)
DOMAINS=""
helm upgrade --install --atomic  --reset-values\
    ${RELEASE_NAME} \
    ./charts/delphai-knative-service \
    --namespace=${REPO_NAME} \
    --set domain=${DOMAIN} \
    --set image=${IMAGE} \
    --set domains="" \
    --set delphaiEnvironment=staging