#!/bin/bash
set -exuo pipefail

kind delete cluster
kind create cluster
kapp deploy -a kpack -y -f https://github.com/pivotal/kpack/releases/download/v0.5.0/release-0.5.0.yaml