#!/bin/bash
set -exuo pipefail
source ./secrets.sh
envsubst envsubst > /tmp/values.yaml << EOF
#@data/values
---
service_account_name: cartographer-example-basic-sc-sa
image_prefix: dev.registry.tanzu.vmware.com/app-live-view/test/
#workload_name: dev
registry:
  server: dev.registry.tanzu.vmware.com
  username: ${DOCKER_USER}
  password: ${DOCKER_PASSWORD}
git:
  user: "${GITHUB_USER}"
  password: "${GITHUB_PASSWORD}"
EOF
ytt --ignore-unknown-comments -f /tmp/values.yaml -f yamls > /tmp/example-setup.yml 
kapp deploy --yes -a example -f /tmp/example-setup.yml