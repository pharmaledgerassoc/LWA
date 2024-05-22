#!/bin/bash

ACTION="${1}"

AWS_ACCOUNT_ID="${2}"

AWS_REGION="${3}"

NETWORK_NAME="${4}"

export GH_TOKEN="${5}"

GIT_USERNAME="${6}"
GIT_EMAIL="${7}"

DNS_DOMAIN="${8}"

EPI_DOMAIN="${9}"

APP_BUILD_VERSION="${10}"

BDNS_JSON_URL="${11}"

HOSTNAME="${12}"

TIME_PER_CALL="${13}"
TOTAL_WAIT_TIME="${14}"
GTO_TIME_PER_CALL="${15}"
GTO_TOTAL_WAIT_TIME="${16}"

LWA_REPO="${17}"
LWA_BRANCH="${18}"

DEPLOYMENT_NAME="LWA"

FQDN=$DNS_DOMAIN

if [[ $HOSTNAME != "" ]];
then
  FQDN="${HOSTNAME}.${DNS_DOMAIN}"
fi

BACKEND_CONFIG_DIRECTORY_PATH="../private/${NETWORK_NAME}/${DEPLOYMENT_NAME}/${FQDN}"

git config --global user.name $GIT_USERNAME
git config --global user.email $GIT_EMAIL
git config --global pull.ff true

mkdir -p ${BACKEND_CONFIG_DIRECTORY_PATH}/terraform

cat <<EOF > terraform.tfvars
aws_region          = "${AWS_REGION}"
dns_domain          = "${DNS_DOMAIN}"
epi_domain          = "${EPI_DOMAIN}"
app_build_version   = "${APP_BUILD_VERSION}"
network_name        = "${NETWORK_NAME}"
bdns_json_url       = "${BDNS_JSON_URL}"
hostname            = "${HOSTNAME}"
time_per_call       = ${TIME_PER_CALL}
total_wait_time     = ${TOTAL_WAIT_TIME}
gto_time_per_call   = ${GTO_TIME_PER_CALL}
gto_total_wait_time = ${GTO_TOTAL_WAIT_TIME}
lwa_repo            = "${LWA_REPO}"
lwa_branch          = "${LWA_BRANCH}"
EOF

terraform init -reconfigure \
  -backend-config="bucket=tf-state-${AWS_REGION}-${AWS_ACCOUNT_ID}" \
  -backend-config="key=${NETWORK_NAME}/${DEPLOYMENT_NAME}/${FQDN}/terraform.tfstate" \
  -backend-config="region=${AWS_REGION}" \
  -backend-config="encrypt=true" \
  -backend-config="dynamodb_table=tf-state-${AWS_REGION}-${AWS_ACCOUNT_ID}"

if [[ -f ${BACKEND_CONFIG_DIRECTORY_PATH}/terraform/bdns.json ]];
then
  mv ${BACKEND_CONFIG_DIRECTORY_PATH}/terraform/bdns.json ./bdns.json
fi

if [[ -f ${BACKEND_CONFIG_DIRECTORY_PATH}/terraform/environment.js ]];
then
  mv ${BACKEND_CONFIG_DIRECTORY_PATH}/terraform/environment.js ./environment.js
fi   

if [[ $ACTION == "destroy" ]] && [[ -f ${BACKEND_CONFIG_DIRECTORY_PATH}/terraform/terraform.tfvars ]];
then
  mv ${BACKEND_CONFIG_DIRECTORY_PATH}/terraform/terraform.tfvars terraform.tfvars
fi

terraform $ACTION --auto-approve

TERRAFORM_RUN_EXIT_CODE=$(echo $?)

mv terraform.tfvars ${BACKEND_CONFIG_DIRECTORY_PATH}/terraform/terraform.tfvars
terraform state pull > ${BACKEND_CONFIG_DIRECTORY_PATH}/terraform/terraform.tfstate

mv ./bdns.json ${BACKEND_CONFIG_DIRECTORY_PATH}/terraform/bdns.json
mv ./environment.js ${BACKEND_CONFIG_DIRECTORY_PATH}/terraform/environment.js

exit $TERRAFORM_RUN_EXIT_CODE
