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
	${container_cli} build . -t ${app_name}:${version}

build-nc: ## Build the container without caching.
	${container_cli} build --no-cache -t ${app_name}:${version}

run-dev: ## Mount this directory into the container and shell in the container interactively.
	${container_cli} run -it --env-file=$(config) -P --entrypoint=/bin/ash --volume .:/opt/cray ${app_name}:${version}

run: ## Run the container
	${container_cli} run --env-file=$(config) -P ${app_name}
