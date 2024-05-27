#!/bin/bash

terraform init -reconfigure \
  -backend-config="bucket=tf-state-${AWS_REGION}-${AWS_ACCOUNT_ID}" \
  -backend-config="key=${TF_network}/LWA/${TF_fqdn}/terraform.tfstate" \
  -backend-config="region=${AWS_REGION}" \
  -backend-config="encrypt=true" \
  -backend-config="dynamodb_table=tf-state-${AWS_REGION}-${AWS_ACCOUNT_ID}"
