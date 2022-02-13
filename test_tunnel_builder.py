""" Unit tests for tunnel_builder. """
from os import environ
import unittest
from unittest import TestCase
from tunnel_builder import TunnelBuilder


class TestTunnelBuilder(TestCase):
    """ Unit tests for the tunnel_builder class. """
    def setUp(self) -> None:
        self.tunnel: TunnelBuilder = TunnelBuilder(
            bastion_ip='127.0.0.1',
            bastion_pass='test_pass',
            endpoint_ip='127.0.0.1'
        )
        self.tunnel2: TunnelBuilder

    def tearDown(self) -> None:
        self.tunnel.destroy_tunnel()
        del self.tunnel

    def test_bastion_ip(self) -> None:
        """ Unit tests for bastion_ip getter and setter. """
        self.assertEqual(self.tunnel.bastion_ip, '127.0.0.1')
        self.tunnel.bastion_ip = '10.10.10.10'
        self.assertEqual(self.tunnel.bastion_ip, '10.10.10.10')

    @unittest.expectedFailure
    def test_bastion_ip_is_bad(self) -> None:
        """ Unit test for an invalid IP set in bastion_ip. """
        self.tunnel.bastion_ip = '234.345.45'

    @unittest.expectedFailure
    def test_bastion_ip_is_blank(self) -> None:
        """ Unit test for setting bastion_ip to nil. """
        self.tunnel.bastion_ip = ''  # Not an IP

    def test_bastion_user(self) -> None:
        """ Unit tests for bastion_user. """
        self.assertEqual(self.tunnel.bastion_user, 'root')
        self.tunnel.bastion_user = 'me'
        self.assertEqual(self.tunnel.bastion_user, 'me')
        self.tunnel.bastion_user = None
        self.assertEqual(self.tunnel.bastion_user, 'root')
        self.tunnel.bastion_user = ""
        self.assertEqual(self.tunnel.bastion_user, 'root')

    def test_bastion_pass(self) -> None:
        """ Unit tests for bastion_pass. """
        self.assertEqual(self.tunnel.bastion_pass, 'test_pass')
        self.tunnel.bastion_pass = 'sup'
        self.assertEqual(self.tunnel.bastion_pass, 'sup')

    @unittest.expectedFailure
    def test_bastion_pass_is_blank(self) -> None:
        """ Unit test for setting bastion_pass to nil. """
        self.tunnel.bastion_pass = ''

    def test_endpoint_ip(self) -> None:
        """ Unit test for setting endpoint_ip addresses. """
        self.assertEqual(self.tunnel.endpoint_ip, '127.0.0.1')
        self.tunnel.endpoint_ip = '10.20.20.20'
        self.assertEqual(self.tunnel.endpoint_ip, '10.20.20.20')

    @unittest.expectedFailure
    def test_endpoint_ip_is_bad(self) -> None:
        """ Unit test for setting endpoint_ip to an invalid IP address. """
        self.tunnel.endpoint_ip = '234.345.45'

    @unittest.expectedFailure
    def test_endpoint_ip_is_blank(self) -> None:
        """ Unit test for setting endpoint_ip to nil. """
        self.tunnel.endpoint_ip = ""

    def test_forward_ports(self) -> None:
        """ Unit tests for setting forward_ports"""
        self.assertEqual(self.tunnel.forward_ports, [22, 443])
        self.tunnel.forward_ports = [10022, 10443]
        self.assertEqual(self.tunnel.forward_ports[0], 10022)

    @unittest.expectedFailure
    def test_forward_ports_is_blank(self) -> None:
        """ Unit test for setting forward_ports to an invalid value. """
        self.tunnel.forward_ports = ''

    @unittest.expectedFailure
    def test_forward_ports_is_bad(self) -> None:
        """ Unit test for setting forward_ports to an invalid value. """
        self.tunnel.forward_ports = 'doh'

    def test_tunnel_with_environment_vars(self) -> None:
        """ Unit tests for instantiating a tunnel with environment variables. """
        environ["BASTION_IP"] = '10.30.30.30'
        environ["BASTION_USER"] = 'thedude'
        environ["BASTION_PASS"] = 'abides'
        environ["ENDPOINT_IP"] = '172.16.16.16'
        self.tunnel2 = TunnelBuilder()
        self.assertEqual(self.tunnel2.bastion_ip, '10.30.30.30')
        self.assertEqual(self.tunnel2.bastion_user, 'thedude')
        self.assertEqual(self.tunnel2.bastion_pass, 'abides')
        self.assertEqual(self.tunnel2.endpoint_ip, '172.16.16.16')
        self.assertEqual(self.tunnel2.forward_ports, [22, 443])

        # Cleanup before other tests run.
        environ["BASTION_IP"] = ''
        environ["BASTION_USER"] = ''
        environ["BASTION_PASS"] = ''
        environ["ENDPOINT_IP"] = ''
        self.tunnel2.destroy_tunnel()
        del self.tunnel2


if __name__ == '__main__':
    unittest.main()
