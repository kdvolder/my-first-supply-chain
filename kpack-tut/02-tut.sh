#!/bin/bash
set -exuo pipefail

kubectl create secret generic tutorial-registry-credentials \
    --from-file=.dockerconfigjson=${HOME}/.docker/config.json \
    --type=kubernetes.io/dockerconfigjson \
    --dry-run=client \
    --output=yaml > /tmp/pullsec.yml

kapp deploy -y -a serviceaccount -f /tmp/pullsec.yml -f yamls

kp build logs tutorial-image -n default

kubectl -n default get image tutorial-image
