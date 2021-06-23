#! /usr/bin/env bash
set -e
kubectx delphai-hybrid

REPO_NAME=news-event-classification-bentoml


IMAGE="delphai.azurecr.io/news-event-classification-bentoml:master"

kubectl create namespace ${REPO_NAME} --output yaml --dry-run=client | kubectl apply -f -
kubectl patch serviceaccount default --namespace ${REPO_NAME} -p "{\"imagePullSecrets\": [{\"name\": \"acr-credentials\"}]}"
helm upgrade --install \
            --wait \
            --namespace ${REPO_NAME} \
            ${REPO_NAME} \
            ./charts/delphai-machine-learning \
            --set image=${IMAGE} \
            --set domain=delphai.red \
            --set delphaiEnvironment=hybrid\
            --set httpPort=5000 \
            --set minScale=1 \
            --set concurrency=30

# helm template --namespace ${REPO_NAME} \
#             ${REPO_NAME} \
#             ./charts/delphai-machine-learning \
#             --set image=${REPO_NAME} \
#             --set domain=delphai.red \
#             --set delphaiEnvironment=hybrid\
#             --set httpPort=5000 \
#             --set minScale=1 \
#             --set concurrency=30 > x.yml
