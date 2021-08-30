#! /usr/bin/env bash
set -e

REPO_NAME=company-scraper
APP_NAME=company-scraper
declare -a STEPS=("main" "find-domain" "crawl" "scrape-page")
IMAGE="delphai.azurecr.io/company-scraper:latest"

for STEP in "${STEPS[@]}"
do
  helm upgrade --install \
              --wait \
              --namespace ${REPO_NAME} \
              ${REPO_NAME}-${STEP} \
              ./charts/delphai-streaming \
              --set image=${IMAGE} \
              --set appName=${APP_NAME} \
              --set step=${STEP}
done