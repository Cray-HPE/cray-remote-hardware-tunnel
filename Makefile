# import config.
# You can change the default config with `make config="test.env" run`
config ?= .env
include $(config)
export $(shell sed 's/=.*//' $(config))

.PHONY: help
help: ## This help.
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

.DEFAULT_GOAL := help

# DOCKER/PODMAN TASKS
# Build the container
build: ## Build the container.
	sudo ${container_cli} build . -t ${app_name}:${version}

build-nc: ## Build the container without caching.
	sudo ${container_cli} build --no-cache -t ${app_name}:${version}

create-network: ## Creates the podman macvlan network on the system's HMN (or local eth0 if testing locally.)
	sudo ${container_cli} network create -d macvlan -o parent=${LOCAL_MACVLAN_FROM} remote_hardware_tunnel

create-sls-entry: ## Adds the new xname in SLS
	echo "TODO: add cray sls command to add the node ${ENDPOINT_XNAME}"

run-dev: ## Mount this directory into the container and shell in the container interactively.
	sudo ${container_cli} run -it --env-file=$(config) --entrypoint=/bin/ash --volume .:/opt/cray \
		--network remote_hardware_tunnel -h ${ENDPOINT_XNAME} --name tunnel_to_${ENDPOINT_XNAME} ${app_name}:${version}

run: ## Run the container
	sudo ${container_cli} run --env-file=$(config) -d --network remote_hardware_tunnel \
		-h ${ENDPOINT_XNAME} --name tunnel_to_${ENDPOINT_XNAME} ${app_name}; \
	sudo podman inspect tunnel_to_${ENDPOINT_XNAME} | grep IPAddress

rm-container: ## Removes the podman container.
	sudo podman rm -f tunnel_to_${ENDPOINT_XNAME}
