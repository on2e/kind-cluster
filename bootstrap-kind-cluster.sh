#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

if ! command -v kind &>/dev/null; then
  echo "kind not found. Install it first to continue."
  exit 1
fi

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"

KIND_CLUSTER_NAME=${KIND_CLUSTER_NAME:-"kind"}
KIND_NODE_IMAGE=${KIND_NODE_IMAGE:-"$(cat KIND_NODE_IMAGE)"}
KIND_CONFIG=${KIND_CONFIG:-"${REPO_DIR}/config.yaml"}
KIND_LOG_VERBOSITY=${KIND_LOG_VERBOSITY:-0}

if kind get clusters -q | grep -x "${KIND_CLUSTER_NAME}" >/dev/null; then
  echo "kind cluster with name \"${KIND_CLUSTER_NAME}\" already exists"
  exit 0
fi

kind create cluster \
  --name "${KIND_CLUSTER_NAME}" \
  --image "${KIND_NODE_IMAGE}" \
  --config "${KIND_CONFIG}" \
  --verbosity "${KIND_LOG_VERBOSITY}" \
  --retain
