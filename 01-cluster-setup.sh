#!/bin/bash
set -exuo pipefail

kind delete cluster
kind create cluster
kubectl config set-context --current --namespace=default

# cert-manager (dependency for cartographer)
kubectl create namespace cert-manager || echo namespace cert-manager exists
kubectl config set-context --current --namespace=cert-manager
kapp deploy -y -a cert-manager -n cert-manager -f https://github.com/jetstack/cert-manager/releases/download/v1.6.1/cert-manager.yaml
kubectl config set-context --current --namespace=default

# cartographer install
kubectl create namespace cartographer-system || echo namespace cartographer-system exists
kapp deploy -y -a cartographer -n default -f https://github.com/vmware-tanzu/cartographer/releases/download/v0.1.0/cartographer.yaml

# kpack install (used by the example supply chain)
KPACK_VERSION=0.4.3
kapp deploy --yes -n default -a kpack \
	-f https://github.com/pivotal/kpack/releases/download/v$KPACK_VERSION/release-$KPACK_VERSION.yaml

# source controller
kubectl create namespace gitops-toolkit || echo namespace exists
kubectl create clusterrolebinding gitops-toolkit-admin \
  --clusterrole=cluster-admin \
  --serviceaccount=gitops-toolkit:default || echo rbac exists
SOURCE_CONTROLLER_VERSION=0.17.0
kapp deploy --yes -a gitops-toolkit \
  --into-ns gitops-toolkit \
  -f https://github.com/fluxcd/source-controller/releases/download/v$SOURCE_CONTROLLER_VERSION/source-controller.crds.yaml \
  -f https://github.com/fluxcd/source-controller/releases/download/v$SOURCE_CONTROLLER_VERSION/source-controller.deployment.yaml

# kapp controller
KAPP_CONTROLLER_VERSION=0.30.0
kapp deploy --yes -a kapp-controller \
	-f https://github.com/vmware-tanzu/carvel-kapp-controller/releases/download/v$KAPP_CONTROLLER_VERSION/release.yml

# knative serving
KNATIVE_SERVING_VERSION=0.26.0
kapp deploy --yes -a knative-serving \
  -f https://github.com/knative/serving/releases/download/v$KNATIVE_SERVING_VERSION/serving-crds.yaml \
  -f https://github.com/knative/serving/releases/download/v$KNATIVE_SERVING_VERSION/serving-core.yaml