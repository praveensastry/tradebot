#!/usr/bin/env bash

set -o errexit

REPO_ROOT=$(git rev-parse --show-toplevel)
export KUBECONFIG="$(kind get kubeconfig-path --name="kind")"

echo '>>> Loading image in Kind'
kind load docker-image test/tradebot:latest

echo '>>> Installing'
helm upgrade -i tradebot ${REPO_ROOT}/charts/tradebot --namespace=default
kubectl set image deployment/tradebot tradebot=test/tradebot:latest
kubectl rollout status deployment/tradebot
