#! /usr/bin/env bash
set -e
kubectx delphai-staging


RELEASE_NAME=subdomain-test

REPO_NAME=subdomain-test

IMAGE=delphaistaging.azurecr.io/delphai-ui-v2@sha256:10f66df4b3a5724e438431c995109e02a1ca7b7e404e6155ba0d1c872014b361

kubectl create namespace ${REPO_NAME} --output yaml --dry-run=client | kubectl apply -f -
kubectl patch serviceaccount default --namespace ${REPO_NAME} -p "{\"imagePullSecrets\": [{\"name\": \"acr-credentials\"}]}"
DOMAIN=$(kubectl get secret domain -o json --namespace default | jq .data.domain -r | base64 -d)
helm upgrade --install --atomic  --reset-values\
    ${RELEASE_NAME} \
    ./charts/delphai-with-ui \
    --namespace=${REPO_NAME} \
    --set domain=${DOMAIN} \
    --set image=${IMAGE} \
    --set httpPort=80 \
    --set delphaiEnvironment=development 
