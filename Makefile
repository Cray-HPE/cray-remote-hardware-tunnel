# import config.
# You can change the default config with `make config="test.env" run`
config ?= .env
include $(config)
export $(shell sed 's/=.*//' $(config))

IMAGE_NAME ?= cray-remote-hardware-tunnel
VERSION ?= $(shell cat .version)

.PHONY: help
help: ## This help.
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

.DEFAULT_GOAL := help

# DOCKER/PODMAN TASKS
# Build the container
build: ## Build the container.
	sudo ${container_cli} build . -t ${IMAGE_NAME}:${VERSION}

build-nc: ## Build the container without caching.
	sudo ${container_cli} build --no-cache -t ${IMAGE_NAME}:${VERSION}

clean: ## Stops the container and dhcp client. Deletes the container and macvlan network.
	make config=$(config) delete-network rm-container

create-network: ## Creates the podman macvlan network and dhcp client for containers using it.
	echo "*** Creating ${container_cli} network remote_hardware_tunnel if missing. ***"
	sudo ${container_cli} network exists remote_hardware_tunnel || \
		sudo ${container_cli} network create -d macvlan -o parent=${LOCAL_MACVLAN_FROM} remote_hardware_tunnel; \
	sudo pgrep -a -F /run/cni/dhcp.pid; \
	if [ $$? -ne 0 ]; then \
		echo "*** Starting up dhcp client. ***"; \
		sudo ls /run/cni/dhcp.sock && sudo rm /run/cni/dhcp.sock || echo "PASS: No dhcp.sock to rm."; \
		sudo ls /run/cni/dhcp.pid && sudo rm /run/cni/dhcp.pid || echo "PASS: No dhcp.pid to rm."; \
		nohup sudo /usr/lib/cni/dhcp daemon --pidfile=/run/cni/dhcp.pid | sudo tee -a /var/log/cni_dhcp_client.log & \
	fi

create-sls-entry: ## Adds the new xname in SLS
	echo "TODO: add cray sls command to add the node ${ENDPOINT_XNAME}"

delete-network: ## Removes CNI network definition and stop dhcp client.
	sudo pgrep -a -F /run/cni/dhcp.pid && \
		sudo pkill -9 -F /run/cni/dhcp.pid; \
	sudo ls /run/cni/dhcp.sock && sudo rm /run/cni/dhcp.sock || echo "PASS: No dhcp.sock to rm."; \
	sudo ls /run/cni/dhcp.pid && sudo rm /run/cni/dhcp.pid || echo "PASS: No dhcp.pid to rm."; \

pull-container: ## Pulls the container down from algol60
	echo "TODO"

run-dev: ## Mount this directory into the container and shell in the container interactively.
	sudo ${container_cli} run -it --env-file=$(config) --entrypoint=/bin/ash --volume .:/opt/cray \
		--network remote_hardware_tunnel -h ${ENDPOINT_XNAME} --name tunnel_to_${ENDPOINT_XNAME} ${IMAGE_NAME}:${VERSION}

run: ## Run the container
	sudo ${container_cli} run --env-file=$(config) -d --network remote_hardware_tunnel \
		-h ${ENDPOINT_XNAME} --name tunnel_to_${ENDPOINT_XNAME} ${IMAGE_NAME}; \
	sudo podman inspect tunnel_to_${ENDPOINT_XNAME} | grep IPAddress

rm-container: ## Removes the podman container.
	if [ ! -z $$(sudo podman ps -a --noheading -f name=tunnel_to_${ENDPOINT_XNAME}) ]; then \
		sudo podman rm -f tunnel_to_${ENDPOINT_XNAME}; \
	fi

up: ## Builds the container, creates the macvlan, and runs the podman container
	make config=$(config) build create-network run
