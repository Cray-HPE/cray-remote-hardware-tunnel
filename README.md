# Cray Remote Hardware Tunnel
Expose a remote environment's hardware endpoint into a local environment via SSH tunnel.

The remote hardware tunnel is useful for testing hardware in another environment from a local CSM instance, e.g. a local dev environment or a TDS. The tunnel requires an accessible SSH endpoint to serve as a bastion host. It exposes the remote hardware's ports 22 and 443 as a local podman container with a MacVLAN interface on the HMN network.

| Local TDS | ----> | Remote M001 or SSH Endpoint | ----> | Hardware |

## Getting Started
You will need the makefile and .env file in this repo on the local environment. The easiest way to proceed is by downloading a copy of the repo.
1. Download this repo to a local node with ip access to the bastion using 
    `wget https://github.com/Cray-HPE/cray-remote-hardware-tunnel/archive/refs/heads/main.tar.gz && tar -xvf main.tar.gz`
1. Copy and edit the .env file to contain the necessary connection parameters for the SSH connection and desired endpoint.
1. Run `make config=[your.env] up`.
1. Confirm the endpoint is in HSM and Kea has provided a DHCP reservation. # TODO: Add commands that add node to CSM.
1. Test CSM services against the remote hardware. # TODO: Add integration test suite.

## Cleaning Up
When testing is complete, run `make config=[your.env] clean`.

## Development
Run `make config=[your.env] run-dev` to mount the local directory into the container for live debugging.

## TODO
- Test whether the podman network works and if the container receives a Kea DHCP reservation.
- Add `make test` and CI pipeline.
- Add the SLS command to add the node.
