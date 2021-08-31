#! /usr/bin/env bash
helm upgrade --install --create-namespace --namespace funding-pipeline funding-page-scraper delphai/delphai-streaming \
  --set autoscaling.consumergroup=funding.page_scraper-funding.page-scraper \
  --set commandLine.STEP=PAGE_SCRAPER \
  --set commandLine.ENDPOINT=page-scraper.grpc.delphai.xyz \
  --set nameOverride=funding-page-scraper \
  --set streams.errorTopic=funding.page-scraper-dead-letter \
  --set streams.inputTopics={funding.news-downloader} \
  --set streams.outputTopic=funding.page-scraper \
  --set autoscaling.minReplicas=1 \
  --set autoscaling.maxReplicas=10

helm upgrade --install --create-namespace --namespace funding-pipeline funding-funding-extractor delphai/delphai-streaming \
  --set autoscaling.consumergroup=funding.funding_extractor-funding.funding-extractor \
  --set commandLine.STEP=FUNDING_EXTRACTOR \
  --set commandLine.ENDPOINT=http://20.71.84.185:80/api/v1/service/newsletter-info/score \
  --set nameOverride=funding-funding-extractor \
  --set streams.errorTopic=funding.funding-extractor-dead-letter \
  --set streams.inputTopics={funding.page-scraper} \
  --set streams.outputTopic=funding.funding-extractor \
  --set autoscaling.minReplicas=1 \
  --set autoscaling.maxReplicas=10