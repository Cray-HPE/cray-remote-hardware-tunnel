# Cray Remote Hardware Tunnel
Expose a remote environment's hardware endpoint into a local environment via SSH tunnel.

The remote hardware tunnel is useful for testing hardware in another environment from a local CSM instance, e.g. a local dev environment or a TDS. The tunnel requires an accessible SSH endpoint to serve as a bastion host. It exposes the remote hardware's ports 22 and 443 as a local podman container with a MacVLAN interface on the HMN network.

| Local TDS | ----> | Remote M001 or SSH Endpoint | ----> | Hardware |

## Getting Started
1. Clone the repo to the local TDS on m001 or a node that has network access to the remote environment.
2. Copy and edit the .env file to contain the necessary connection parameters for the SSH connection.
3. Pull the container image or run `make config=[your.env] build-nc`.
4. Run `make config=[your.env] create-sls-entry`.
5. Run `make config=[your.env] create-network`.
6. Run `make config=[your.env] run`.
7. Confirm the endpoint is in HSM and Kea has provided a DHCP reservation.
8. Test CSM services against the remote hardware.

## Development
Run the same steps as above but use `make config=[your.env] run-dev` instead for step 6. This will mount the local directory into the container for live debugging.

## TODO
- Create `make clean` to delete the podman network and remove the xname in SLS.
- Test whether the podman network works and if the container receives a Kea DHCP reservation.
- Add `make test` and CI pipeline.
- Add the SLS command to add the node.
- Finish the `make create-network` command

