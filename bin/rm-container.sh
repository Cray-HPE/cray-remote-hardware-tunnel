#!/usr/bin/env bash
set -ex

if [[ ! -z $(sudo podman ps -a --noheading -f name=tunnel_to_${ENDPOINT_XNAME}) ]]; then
	sudo podman rm -f tunnel_to_${ENDPOINT_XNAME}
fi
