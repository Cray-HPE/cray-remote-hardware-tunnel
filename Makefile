# import config.
# You can change the default config with `make config="test.env" run`
export config ?= .env
include $(config)
export $(shell sed 's/=.*//' $(config))

export IMAGE_NAME ?= cray-remote-hardware-tunnel
export VERSION ?= $(shell cat .version)

.PHONY: help
help: ## This help.
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

.DEFAULT_GOAL := help

# DOCKER/PODMAN TASKS
# Build the container
build: ## Build the container.
	bin/build.sh

build-nc: ## Build the container without caching.
	bin/build-nc.sh

clean: ## Stops the container and dhcp client. Deletes the container and macvlan network.
	make config=$(config) delete-network rm-container

create-network: ## Creates the podman macvlan network and dhcp client for containers using it.
	bin/create-network.sh

create-sls-entry: ## Adds the new xname in SLS
	echo "TODO: add cray sls command to add the node ${ENDPOINT_XNAME}"

delete-network: ## Removes CNI network definition and stop dhcp client.
	bin/delete-network.sh

pull-container: ## Pulls the container down from algol60
	echo "TODO: build a stable and incorporate latest tag"; \
	bin/pull-container.sh

run-dev: ## Mount this directory into the container and shell in the container interactively.
	bin/run-dev.sh

run: ## Run the container
	bin/run.sh

rm-container: ## Removes the podman container.
	bin/rm-container.sh

up: ## Builds the container, creates the macvlan, and runs the podman container
	make config=$(config) create-network run
