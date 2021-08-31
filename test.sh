#! /usr/bin/env bash
set -e

REPO_NAME=company-scraper
APP_NAME=company-scraper
STEPS="main,find-domain,crawl,scrape-page"
IMAGE="delphai.azurecr.io/company-scraper:latest"
helm upgrade --install \
              --wait \
              --namespace ${REPO_NAME} \
              ${REPO_NAME} \
              ./charts/delphai-streaming \
              --set image=${IMAGE} \
              --set "steps={${STEPS}}"