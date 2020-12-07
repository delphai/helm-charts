#! /usr/bin/env bash
set -e
kubectx delphai-common

RELEASE_NAME=page-classification-bentoml

REPO_NAME=page-classification-bentoml

IMAGE=delphaicommon.azurecr.io/page-classification-bentoml@sha256:94cf3fce78f5dc465227c7f61a5332042c24b0289eea2f5d45f0e4b0e848509b

kubectl create namespace ${REPO_NAME} --output yaml --dry-run=client | kubectl apply -f -
kubectl patch serviceaccount default --namespace ${REPO_NAME} -p "{\"imagePullSecrets\": [{\"name\": \"acr-credentials\"}]}"
DOMAIN=$(kubectl get secret domain -o json --namespace default | jq .data.domain -r | base64 -d)
helm upgrade --install --atomic  --reset-values\
    ${RELEASE_NAME} \
    ./charts/delphai-machine-learning \
    --namespace=${REPO_NAME} \
    --set domain=${DOMAIN} \
    --set image=${IMAGE} \
    --set httpPort=5000 \
    --set delphaiEnvironment=common \
    --set minScale=0