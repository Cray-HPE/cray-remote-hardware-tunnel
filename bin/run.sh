#!/usr/bin/env bash
set -ex
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
${SCRIPT_DIR}/rm-container.sh

sudo ${container_cli} run --env-file=${config} -d --network remote_hardware_tunnel \
    -h ${ENDPOINT_XNAME} --name tunnel_to_${ENDPOINT_XNAME} ${IMAGE_REPO}/${IMAGE_NAME}:${VERSION}
sudo podman inspect tunnel_to_${ENDPOINT_XNAME} | grep IPAddress
echo "This IP address is not routeable from this host. You can now ssh from another NCN and hit this IP address."
