#! /usr/bin/env python3
""" Executor for the remote tunnel. """
import logging
import signal
import sys
import time

from tunnel_builder import TunnelBuilder

tunnel: TunnelBuilder = TunnelBuilder()
Log_Format = "%(levelname)s %(asctime)s - %(message)s"

logging.basicConfig(stream=sys.stdout,
                    filemode="w",
                    format=Log_Format,
                    level=logging.INFO)


def signal_handler(signal, frame) -> None:
    tunnel.destroy_tunnel()
    print("Program exited gracefully")
    sys.exit(0)


if __name__ == "__main__":
    if tunnel.tunnel.is_alive:
        print(f'Tunnel through {tunnel.bastion_ip} to {tunnel.endpoint_ip} is active.')
        print('Ctrl-C to stop.')
    else:
        raise ConnectionError(f'Tunnel through {tunnel.bastion_ip} to {tunnel.endpoint_ip} failed.')
    while tunnel.tunnel.is_alive:
        try:
            time.sleep(5)
        except KeyboardInterrupt:
            print('Closing down tunnel and exiting.')
            signal.signal(signal.SIGINT, signal_handler)
            break
    raise ConnectionError(f'Tunnel through {tunnel.bastion_ip} to {tunnel.endpoint_ip} failed.')