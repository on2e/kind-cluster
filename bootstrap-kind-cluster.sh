#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

if ! command -v kind &>/dev/null; then
  echo "kind is not installed, aborting"
  exit 1
fi

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"

KIND_CLUSTER_NAME=${KIND_CLUSTER_NAME:-"kind"}
KIND_NODE_IMAGE=${KIND_NODE_IMAGE:-"kindest/node:v1.34.0@sha256:7416a61b42b1662ca6ca89f02028ac133a309a2a30ba309614e8ec94d976dc5a"}
KIND_CONFIG=${KIND_CONFIG:-"${REPO_DIR}/config.yaml"}
KIND_LOG_VERBOSITY=${KIND_LOG_VERBOSITY:-0}

if kind get clusters -q | grep -x "${KIND_CLUSTER_NAME}" >/dev/null; then
  echo "kind cluster with name \"${KIND_CLUSTER_NAME}\" already exists, skipping"
  exit 0
fi

kind create cluster \
  --name "${KIND_CLUSTER_NAME}" \
  --image "${KIND_NODE_IMAGE}" \
  --config "${KIND_CONFIG}" \
  --verbosity "${KIND_LOG_VERBOSITY}" \
  --retain
