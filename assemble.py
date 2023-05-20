import io
import hashlib
from time import time
from random import randint

from kaitaistruct import KaitaiStream
import kaitai_gen.out.bitmessage as b


def checksum(payload):
    return int.from_bytes(hashlib.sha512(payload).digest()[0:4], "big")


def assemble_packet(command, payload: bytes):
    header = b.Bitmessage.MessageHeader()
    header.magic = bytes([0xE9, 0xBE, 0xB4, 0xD9])
    header.command = command
    header.length = len(payload)
    header.checksum = checksum(payload)
    header._check()
    _io = KaitaiStream(io.BytesIO(bytearray(24)))
    header._write(_io)
    output = _io.to_byte_array()[: _io.pos()]
    return output + payload


def assemble_version_payload():
    payload = b.Bitmessage().MessageVersionType()
    payload.version = 3
    payload.services = 1
    payload.timestamp = int(time())
    payload.nonce = randint(0, (1 << 64) - 1)
    localhost = b.Bitmessage().NotPrefixedNetAddr()
    localhost.ip = bytes([0] * 10 + [0xFF] * 2 + [127, 0, 0, 1])
    localhost.port = 8444
    localhost.services = 1
    localhost._check()
    localhost._parent = payload
    payload.addr_recv = localhost
    payload.addr_from = localhost
    user_agent = b.Bitmessage().VarStr.from_bytes(b"\x0c/test:0.0.1/")
    user_agent._read()
    user_agent._parent = payload
    payload.user_agent = user_agent
    stream_numbers = b.Bitmessage().VarIntList().from_bytes(b"\x01\x01")
    stream_numbers._read()
    stream_numbers._parent = payload
    payload.stream_numbers = stream_numbers
    payload._check()

    _io = KaitaiStream(io.BytesIO(bytearray(128)))
    payload._write(_io)
    output = _io.to_byte_array()[: _io.pos()]
    return output


def assemble_empty_addr():
    return assemble_packet("addr", bytes([1]+[0]*38))


def assemble_empty_inv():
    return assemble_packet("inv", bytes([1]+[0]*32))


def assemble_simple_getdata(inv_vect: bytes):
    payload = b.Bitmessage().MessageGetdataType().from_bytes(b"\x01" + inv_vect)
    payload._read()
    _io = KaitaiStream(io.BytesIO(bytearray(40)))
    payload._write(_io)
    output = _io.to_byte_array()[: _io.pos()]
    return assemble_packet("getdata", output)