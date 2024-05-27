#!/bin/bash

terraform init -reconfigure \
  -backend-config="bucket=tf-state-${AWS_REGION}-${AWS_ACCOUNT_ID}" \
  -backend-config="key=${NETWORK_NAME}/LWA/${FQDN}/terraform.tfstate" \
  -backend-config="region=${AWS_REGION}" \
  -backend-config="encrypt=true" \
  -backend-config="dynamodb_table=tf-state-${AWS_REGION}-${AWS_ACCOUNT_ID}"
