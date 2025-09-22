SHELL = /usr/bin/env bash
.SHELLFLAGS = -o errexit -o nounset -o pipefail -c

KIND_CLUSTER_NAME  ?= kind
KIND_NODE_IMAGE    ?= kindest/node:v1.34.0@sha256:7416a61b42b1662ca6ca89f02028ac133a309a2a30ba309614e8ec94d976dc5a
KIND_CONFIG        ?= $(CURDIR)/config.yaml
KIND_LOG_VERBOSITY ?= 0

.PHONY: all
all: create

##@ General

.PHONY: help
help: ## Display this help message
	@awk 'BEGIN {FS = ":.*##"; printf "\nUsage:\n  make \033[36m<target>\033[0m\n"} /^[a-zA-Z_0-9-]+:.*?##/ { printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2 } /^##@/ { printf "\n\033[1m%s\033[0m\n", substr($$0, 5) } ' $(MAKEFILE_LIST)

##@ Kind

.PHONY: create
create: ## Create kind cluster
	@KIND_CLUSTER_NAME=$(KIND_CLUSTER_NAME) \
	KIND_NODE_IMAGE=$(KIND_NODE_IMAGE) \
	KIND_CONFIG=$(KIND_CONFIG) \
	KIND_LOG_VERBOSITY=$(KIND_LOG_VERBOSITY) \
	./bootstrap-kind-cluster.sh

.PHONY: delete
delete: ## Delete kind cluster
	@kind delete cluster --name $(KIND_CLUSTER_NAME)
