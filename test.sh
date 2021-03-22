#! /usr/bin/env bash
set -e
kubectx delphai-hybrid

RELEASE_NAME=ml-utils

REPO_NAME=ml-utils

IMAGE=delphaicommon.azurecr.io/ml-utils:latest

kubectl create namespace ${REPO_NAME} --output yaml --dry-run=client | kubectl apply -f -
kubectl patch serviceaccount default --namespace ${REPO_NAME} -p "{\"imagePullSecrets\": [{\"name\": \"acr-credentials\"}]}"
helm upgrade --install --atomic  --reset-values\
    ${RELEASE_NAME} \
    ./charts/delphai-machine-learning \
    --namespace=${REPO_NAME} \
    --set domain='delphai.site' \
    --set image=${IMAGE} \
    --set train=true \
    --set delphaiEnvironment=ml \
    --set gpu=true


