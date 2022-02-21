#!/usr/bin/env bash
set -ex

if [[ ! -z $(sudo ${container_cli} network ls -q --filter name=remote_hardware_tunnel) ]]; then
    sudo ${container_cli} network rm -f remote_hardware_tunnel
fi

if [[ -f /run/cni/dhcp.pid && $(sudo pgrep -a -F /run/cni/dhcp.pid) ]]; then
	sudo pkill -9 -F /run/cni/dhcp.pid
fi
sudo ls /run/cni/dhcp.sock && sudo rm /run/cni/dhcp.sock || echo "PASS: No dhcp.sock to rm."
sudo ls /run/cni/dhcp.pid && sudo rm /run/cni/dhcp.pid || echo "PASS: No dhcp.pid to rm."