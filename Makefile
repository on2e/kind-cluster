SHELL = /usr/bin/env bash
.SHELLFLAGS = -o errexit -o nounset -o pipefail -c

KIND_CLUSTER_NAME  ?= kind
KIND_NODE_IMAGE    ?= $(shell cat KIND_NODE_IMAGE)
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
	@if ! command -v kind &>/dev/null; then \
		echo >&2 "kind not found. Install it first or set \$$PATH to continue."; \
		exit 1; \
	fi
	@if kind get clusters -q | grep -x $(KIND_CLUSTER_NAME) >/dev/null; then \
		echo "kind cluster with name \"$(KIND_CLUSTER_NAME)\" already exists"; \
	else \
		kind create cluster \
			--name $(KIND_CLUSTER_NAME) \
			--image $(KIND_NODE_IMAGE) \
			--config $(KIND_CONFIG) \
			--verbosity $(KIND_LOG_VERBOSITY) \
			--retain; \
	fi

.PHONY: delete
delete: ## Delete kind cluster
	@kind delete cluster --name $(KIND_CLUSTER_NAME)

##@ Deployments

.PHONY: install-ingress-nginx
install-ingress-nginx: ## Install ingress-nginx (specified in deployments/ingress-nginx/install.yaml)
	@echo
	@echo -e "Installing \033[32mingress-nginx\033[0m"
	@echo
	@kubectl apply -f deployments/ingress-nginx/install.yaml

.PHONY: uninstall-ingress-nginx
uninstall-ingress-nginx: ## Uninstall ingress-nginx (specified in deployments/ingress-nginx/install.yaml)
	@echo
	@echo -e "Uninstalling \033[32mingress-nginx\033[0m"
	@echo
	@kubectl delete --ignore-not-found -f deployments/ingress-nginx/install.yaml

.PHONY: install-postgresql
install-postgresql: ## Install postgresql (specified in deployments/postgresql/install.yaml)
	@echo
	@echo -e "Installing \033[32mpostgresql\033[0m"
	@echo
	@kubectl apply -f deployments/postgresql/install.yaml

.PHONY: uninstall-postgresql
uninstall-postgresql: ## Uninstall postgresql (specified in deployments/postgresql/install.yaml)
	@echo
	@echo -e "Uninstalling \033[32mpostgresql\033[0m"
	@echo
	@kubectl delete --ignore-not-found -f deployments/postgresql/install.yaml
