#!/usr/bin/env bash
set -ex
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
${SCRIPT_DIR}/rm-container.sh

sudo ${container_cli} run -it --env-file=${config} --entrypoint=/bin/ash --volume .:/opt/cray \
	--network remote_hardware_tunnel -h ${ENDPOINT_XNAME} --name tunnel_to_${ENDPOINT_XNAME} ${IMAGE_NAME}:${VERSION}