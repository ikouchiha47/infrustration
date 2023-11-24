#!/bin/bash
#
# Apply eks kubernetes config


VERSION=$(git rev-parse --short HEAD)
DOCKER_BUILD_TAG="talon-server:${VERSION}"

function setup_cluster() {
  FILE="./infrafiles/eks/deployment.yaml"
  AWS_ACCOUNT=${AWS_ACCOUNT} IMAGE="${DOCKER_BUILD_TAG}" envsubst < "${FILE}" | kubectl apply -f -
}

if [[ "$1" == "setup" ]]; then
  setup_cluster
fi
