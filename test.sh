#! /usr/bin/env bash
set -e
kubectx delphai-development

RELEASE_NAME=delphai-ui-test
REPO_NAME=delphai-ui-test
IMAGE=delphaistaging.azurecr.io/delphai-ui@sha256:be812a130f8dd9a470b8d9dd6332a0ab549cefecd0bfd4feef49fc7faa6dd214

kubectl create namespace ${REPO_NAME} --output yaml --dry-run=client | kubectl apply -f -
kubectl patch serviceaccount default --namespace ${REPO_NAME} -p "{\"imagePullSecrets\": [{\"name\": \"acr-credentials\"}]}"
DOMAIN=$(kubectl get secret domain -o json --namespace default | jq .data.domain -r | base64 -d)
DOMAINS=""
helm upgrade --install --atomic  --reset-values\
    ${RELEASE_NAME} \
    ./charts/delphai-with-ui \
    --namespace=${REPO_NAME} \
    --set httpPort=80 \
    --set domain=${DOMAIN} \
    --set domains=${DOMAINS} \
    --set delphaiEnvironment=development