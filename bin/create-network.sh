#!/usr/bin/env bash
set -ex
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

echo "*** Creating ${container_cli} network remote_hardware_tunnel if missing. ***"
$SCRIPT_DIR/delete-network.sh
sudo ${container_cli} network create -d macvlan -o parent=${LOCAL_MACVLAN_FROM} remote_hardware_tunnel
nohup sudo /usr/lib/cni/dhcp daemon --pidfile=/run/cni/dhcp.pid | sudo tee -a /var/log/cni_dhcp_client.log &
