import socket
import time
import select

import sys
sys.path.append("kaitai_gen/out")

from pybitmsg import bitmsg
from kaitai_gen.out import bitmessage as b
from kaitaistruct import ValidationNotEqualError
from assemble import *

invs = set()

def hello(s):
    s.sendall(assemble_packet("version", assemble_version_payload()))

def handle_message(s, msg):
    msg = msg.message
    print(f"{msg.header.command} from {s.getpeername()}")
    if (msg.header.command == "version"):
        s.sendall(assemble_packet("verack", b""))
        s.sendall(assemble_empty_addr())
        s.sendall(assemble_empty_inv())
    if (msg.header.command == "addr"):
        remotes = []
        for addr in msg.payload.addr_list:
            import ipaddress
            remote = ((ipaddress.ip_address(addr.payload.ip[-4:]).__str__(), addr.payload.port))
            remotes.append(remote)
        print(remotes)
        exit()
    if (msg.header.command == "inv"):
        for vect in msg.payload.inventory:
            if vect.hash not in invs:
                s.sendall(assemble_simple_getdata(vect.hash))
                invs.add(vect.hash)
                print(f"There are {len(invs)} invs")
    if (msg.header.command == "object"):
        print(msg.payload.object_payload_type)
        if(msg.payload.object_payload_type == "broadcast"):
            print(msg.payload.object_payload)
            exit()


def handle_socket(socket):
    s = socket
    try:
        data = s.recv(2*1024)
    except:
        return
    if data:
        msg = b.Bitmessage.from_bytes(data)
        while True:
            try:
                msg._read()
            except:
                return
            handle_message(s, msg)


if __name__ == "__main__":
    hosts = []
    for host in socket.gethostbyname_ex("bootstrap8444.bitmessage.org")[2]:
        if host not in hosts:
            hosts.append((host, 8444))
    for host in socket.gethostbyname_ex("bootstrap8080.bitmessage.org")[2]:
        if host not in hosts:
            hosts.append((host, 8080))
    sockets = []
    for i, host in enumerate(hosts):
        print(f"#{i}")
        try:
            s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
            s.settimeout(0.25)
            s.connect(host)
            s.settimeout(None)
            #s.setblocking(False)
        except Exception as e:
            print(e)
            continue
        sockets.append(s)
        print(sockets)
        hello(s)
        handle_socket(s)
    while True:
        readable, _, _ = select.select(sockets, [], [])
        for connection in readable:
            #print(connection)
            handle_socket(connection)

