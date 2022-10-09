#!/usr/bin/env python

# This is to let us connect datastudio to postgres in heroku, by generating a certificate.

# RUN AS:
# AWS_DATABASE_SERVER="hostname of postgres instance"
# python scripts/generate-datastudio-pemkey.py AWS_DATABASE_SERVER:5432 > aws-cert.pem

# you'll then plug conn creds into datastudio and upload the pem file
# the above command generates.

# Origins in: https://stackoverflow.com/a/48994943

import argparse
import socket
import ssl
import struct
import subprocess
import sys

try:
    from urlparse import urlparse
except ImportError:
    from urllib.parse import urlparse


def main():
    args = get_args()
    target = get_target_address_from_args(args)
    sock = socket.create_connection(target)
    try:
        certificate_as_pem = get_certificate_from_socket(sock)
        print(certificate_as_pem.decode('utf-8'))
    except Exception as exc:
        sys.stderr.write('Something failed while fetching certificate: {0}\n'.format(exc))
        sys.exit(1)
    finally:
        sock.close()


def get_args():
    parser = argparse.ArgumentParser()
    parser.add_argument('database', help='Either an IP address, hostname or URL with host and port')
    return parser.parse_args()


def get_target_address_from_args(args):
    specified_target = args.database
    if '//' not in specified_target:
        specified_target = '//' + specified_target
    parsed = urlparse(specified_target)
    return (parsed.hostname, parsed.port or 5432)


def get_certificate_from_socket(sock):
    request_ssl(sock)
    ssl_context = get_ssl_context()
    sock = ssl_context.wrap_socket(sock)
    sock.do_handshake()
    certificate_as_der = sock.getpeercert(binary_form=True)
    certificate_as_pem = encode_der_as_pem(certificate_as_der)
    return certificate_as_pem


def request_ssl(sock):
    # 1234.5679 is the magic protocol version used to request TLS, defined
    # in pgcomm.h)
    version_ssl = postgres_protocol_version_to_binary(1234, 5679)
    length = struct.pack('!I', 8)
    packet = length + version_ssl

    sock.sendall(packet)
    data = read_n_bytes_from_socket(sock, 1)
    if data != b'S':
        raise Exception('Backend does not support TLS')


def get_ssl_context():
    # Return the strongest SSL context available locally
    for proto in ('PROTOCOL_TLSv1_2', 'PROTOCOL_TLSv1', 'PROTOCOL_SSLv23'):
        protocol = getattr(ssl, proto, None)
        if protocol:
            break
    return ssl.SSLContext(protocol)


def encode_der_as_pem(cert):
    # Forking out to openssl to not have to add any dependencies to script,
    # preferably you'd do this with pycrypto or other ssl libraries.
    cmd = ['openssl', 'x509', '-inform', 'DER']
    pipe = subprocess.PIPE
    process = subprocess.Popen(cmd, stdin=pipe, stdout=pipe, stderr=pipe)
    stdout, stderr = process.communicate(cert)
    if stderr:
        raise Exception('OpenSSL error when converting cert to PEM: {0}'.format(stderr))
    return stdout.strip()


def read_n_bytes_from_socket(sock, n):
    buf = bytearray(n)
    view = memoryview(buf)
    while n:
        nbytes = sock.recv_into(view, n)
        view = view[nbytes:] # slicing views is cheap
        n -= nbytes
    return buf


def postgres_protocol_version_to_binary(major, minor):
    return struct.pack('!I', major << 16 | minor)


if __name__ == '__main__':
    main()

