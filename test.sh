#! /usr/bin/env bash
set -e
# Variables
DELPHAI_ENVIRONMENT=common
REPO_NAME=delphai-ui
REPO_SLUG=feat-multiple-domains
IMAGE=delphaireview.azurecr.io/delphai-ui:feat-multiple-domains@sha256:5c01cff6fc5d1861825a72711c4e7a3cd6c9886443143c3945fa4a1207277389
HTTPPORT=80
DOMAINS='{delpha.red,delphai.blue}'
IS_UI=true
IS_MICROSERVICE=false
RELEASE_NAME=${REPO_NAME}-${REPO_SLUG}
kubectx delphai-$1


#Helming
kubectl create namespace ${REPO_NAME} --output yaml --dry-run=client | kubectl apply -f -
kubectl patch serviceaccount default --namespace ${REPO_NAME} -p "{\"imagePullSecrets\": [{\"name\": \"acr-credentials\"}]}"
helm repo add delphai https://delphai.github.io/helm-charts && helm repo update

if [ "${DELPHAI_ENVIRONMENT}" == "GREEN" ] || [ "${DELPHAI_ENVIRONMENT}" == "LIVE" ]; then
    DELPHAI_ENVIRONMENT_ENV_VAR=production
else
    DELPHAI_ENVIRONMENT_ENV_VAR=${DELPHAI_ENVIRONMENT}
fi

echo "${DOMAINS}"
if  [ "${IS_UI}" == "true" ] && [ "${IS_MICROSERVICE}" == "false" ] ; then
    echo "Using helm delphai-with-ui"
    helm upgrade --install --wait --atomic \
          ${RELEASE_NAME} \
          delphai/delphai-with-ui \
          --namespace=${REPO_NAME} \
          --set image=${IMAGE} \
          --set httpPort=${HTTPPORT} \
          --set domains=${DOMAINS} \
          --set delphaiEnvironment=${DELPHAI_ENVIRONMENT_ENV_VAR}
    kubectl patch deployment ${RELEASE_NAME} --namespace ${REPO_NAME} -p "{\"spec\":{\"template\":{\"metadata\":{\"labels\":{\"date\":\"`date +'%s'`\"}}}}}"
elif   [ "${IS_UI}" == "false" ] && [ "${IS_MICROSERVICE}" == "false" ] ; then
    echo "Using helm delphai-knative service"
    helm upgrade --install --wait --atomic \
          ${RELEASE_NAME} \
          delphai/delphai-knative-service \
          --namespace=${REPO_NAME} \
          --set image=${IMAGE} \
          --set httpPort=${HTTPPORT} \
          --set grpcPort=${GRPCPORT} \
          --set isPublic=${IS_PUBLIC} \
          --set isUi=${IS_UI} \
          --set domain=${DOMAINS} \
          --set delphaiEnvironment=${DELPHAI_ENVIRONMENT_ENV_VAR} 
elif  [ "${IS_UI}" == "false" ] && [ "${IS_MICROSERVICE}" == "true" ] ; then
    echo "Using helm delphai-microservice service"
    helm upgrade --install --wait --atomic \
          ${RELEASE_NAME} \
          delphai/delphai-microservice \
          --namespace=${REPO_NAME} \
          --set image=${IMAGE} \
          --set replicas=1 \
          --set gatewayPort=7070 \
          --set deployGateway=false\
          --set authRequired=false\
          --set delphaiEnvironment=${DELPHAI_ENVIRONMENT_ENV_VAR} \
          --set domain=${DOMAINS} \
          --set fileShares=${FILE_SHARES}
fi

echo -e "\e[32mImportantInfo"
echo -e "image:${IMAGE},\nenviroment:${DELPHAI_ENVIRONMENT},\nrelease:${RELEASE_NAME},\nrepo_name:${REPO_NAME},\nrepo_slug:${REPO_SLUG},\nhttpPort:${HTTPPORT}\ndomain:${DOMAINS},\nIs_public:${IS_PUBLIC},\nIs_Ui:${IS_UI}\nis_runner:${IS_RUNNER}\n\n\n"
echo "██████  ███████ ██      ██████  ██   ██  █████  ██ ";
echo "██   ██ ██      ██      ██   ██ ██   ██ ██   ██ ██ ";
echo "██   ██ █████   ██      ██████  ███████ ███████ ██ ";
echo "██   ██ ██      ██      ██      ██   ██ ██   ██ ██ ";
echo "██████  ███████ ███████ ██      ██   ██ ██   ██ ██ ";
echo "                                                   ";
echo "                                                   ";