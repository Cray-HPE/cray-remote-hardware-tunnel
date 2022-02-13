""" Creates an ssh tunnel to remote device exposing ports 22 and 443."""
from os import getenv
import ipaddress
import sys
from sshtunnel import SSHTunnelForwarder


class TunnelBuilder:
    """ Creates an ssh tunnel proxy through a bastion host to a remote machine's port. """

    def __init__(self,
                 bastion_ip: str = '',
                 bastion_pass: str = '',
                 endpoint_ip: str = ''):
        self._bastion_ip: str = getenv("BASTION_IP", bastion_ip)
        self._bastion_user: str = getenv("BASTION_USER", 'root')
        self._bastion_pass: str = getenv("BASTION_PASS", bastion_pass)
        self._endpoint_ip: str = getenv("ENDPOINT_IP", endpoint_ip)
        self._forward_ports: list = [22, 443]
        self.tunnel: SSHTunnelForwarder = self.create_tunnel()
        self.tunnel.start()

    # bastion_ip getter and setter
    @property
    def bastion_ip(self) -> str:
        """ Returns bastion_ip property. """
        if not self._bastion_ip:
            raise ValueError("No Bastion IP address provided.")
        return self._bastion_ip

    @bastion_ip.setter
    def bastion_ip(self, bip: str) -> None:
        try:
            ip_address = ipaddress.ip_address(bip)
            print(f'Bastion IP {ip_address} is a correct IP{ip_address.version} address.')
        except ValueError:
            print(f'Bastion IP address/netmask is invalid: {sys.argv[1]}')
        self._bastion_ip = bip

    # bastion_user getter and setter
    @property
    def bastion_user(self) -> str:
        """ Returns bastion_user property. """
        return self._bastion_user

    @bastion_user.setter
    def bastion_user(self, bus: str) -> None:
        if not bus or not isinstance(bus, str):
            print("Bastion User not set or not a string. Using 'root'.")
            self._bastion_user = "root"
        else:
            self._bastion_user = bus

    # bastion_pass getter and setter
    @property
    def bastion_pass(self) -> str:
        """ Returns bastion_pass property. """
        if not self._bastion_pass:
            raise ValueError("No ssh password provided for the bastion host.")
        return self._bastion_pass

    @bastion_pass.setter
    def bastion_pass(self, b_pass: str) -> None:
        if not b_pass:
            raise ValueError(
                "Environment variable 'BASTION_PASS' or arg 'bastion_pass' must not be blank.")
        self._bastion_pass = b_pass

    # endpoint_ip getter and setter
    @property
    def endpoint_ip(self) -> str:
        """ Returns endpoint_ip property. """
        if not self._endpoint_ip:
            raise ValueError('No hardware endpoint IP address specified.')
        return self._endpoint_ip

    @endpoint_ip.setter
    def endpoint_ip(self, eip: str) -> None:
        try:
            ip_address = ipaddress.ip_address(eip)
            print(f'Endpoint IP {ip_address} is a correct IP{ip_address} address.')
        except ValueError:
            print(f'Endpoint IP address/netmask is invalid: {sys.argv[1]}')
        self._endpoint_ip = eip

    # endpoint_port getter and setter
    @property
    def forward_ports(self) -> list:
        """ Returns endpoint_ports property. """
        return self._forward_ports

    @forward_ports.setter
    def forward_ports(self, fps: list) -> None:
        if not fps:
            raise ValueError("Property 'forward_ports' must not be blank.")
        if not len(fps) == 2:
            raise ValueError("Property 'forward_ports' must have two values.")  # TODO: Make this dynamic.
        self._forward_ports = fps

    # Public instance methods
    def create_tunnel(self) -> SSHTunnelForwarder:
        """ Initializes the tunnel. """
        return SSHTunnelForwarder(
            (self.bastion_ip, 22),
            ssh_username=self.bastion_user,
            ssh_password=self.bastion_pass,
            remote_bind_addresses=[
                (self.endpoint_ip, self.forward_ports[0]),
                (self.endpoint_ip, self.forward_ports[1])
                ],
            local_bind_addresses=[
                ('0.0.0.0', self.forward_ports[0]),
                ('0.0.0.0', self.forward_ports[1]),
                ]
        )

    def destroy_tunnel(self):
        """ Destroys tunnel. """
        self.tunnel.close()
        del self.tunnel
