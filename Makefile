SHELL = /usr/bin/env bash
.SHELLFLAGS = -o errexit -o nounset -o pipefail -c

KIND               ?= $(HOME)/.local/bin/kind
KIND_VERSION       ?= $(shell cat KIND_VERSION)

KIND_CLUSTER_NAME  ?= kind
KIND_NODE_IMAGE    ?= $(shell cat KIND_NODE_IMAGE)
KIND_CONFIG        ?= $(CURDIR)/config.yaml
KIND_LOG_VERBOSITY ?= 0

.PHONY: all
all: create install-ingress-nginx

##@ General

.PHONY: help
help: ## Display this help message
	@awk 'BEGIN {FS = ":.*##"; printf "\nUsage:\n  make \033[36m<target>\033[0m\n"} /^[a-zA-Z_0-9-]+:.*?##/ { printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2 } /^##@/ { printf "\n\033[1m%s\033[0m\n", substr($$0, 5) } ' $(MAKEFILE_LIST)

##@ Kind

define kind_version_has
$$($(KIND) version | cut -d' ' -f2)
endef

.PHONY: kind
kind: ## Install kind from release binary (if wrong version is installed, it will be removed)
	@if [[ -x $(KIND) && $(kind_version_has) != $(KIND_VERSION) ]]; then \
		echo "$(KIND) version is $(kind_version_has), but $(KIND_VERSION) is specified. Removing it before installing."; \
		rm -rf $(KIND); \
	fi
	@if [[ ! -x $(KIND) ]]; then \
		curl -sSfL -o kind "https://kind.sigs.k8s.io/dl/$(KIND_VERSION)/kind-linux-amd64"; \
		chmod +x kind; \
		mv kind $(KIND); \
	fi
	@echo $(kind_version_has)

.PHONY: create
create: ## Create kind cluster
	@if ! command -v kind &>/dev/null; then \
		echo "kind not found. Install it first or set \$$PATH to continue." >&2; \
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
install-ingress-nginx: ## Install Ingress NGINX controller (specified in deployments/ingress-nginx/install.yaml)
	@echo
	@echo -e "Installing \033[32mIngress NGINX controller\033[0m"
	@echo
	@kubectl apply -f deployments/ingress-nginx/install.yaml

.PHONY: uninstall-ingress-nginx
uninstall-ingress-nginx: ## Uninstall Ingress NGINX controller (specified in deployments/ingress-nginx/install.yaml)
	@echo
	@echo -e "Uninstalling \033[32mIngress NGINX controller\033[0m"
	@echo
	@kubectl delete -f deployments/ingress-nginx/install.yaml
