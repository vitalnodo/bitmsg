# This is a generated file! Please edit source .ksy file and use kaitai-struct-compiler to rebuild
# type: ignore

import kaitaistruct
from kaitaistruct import ReadWriteKaitaiStruct, KaitaiStream, BytesIO
from enum import IntEnum


if getattr(kaitaistruct, 'API_VERSION', (0, 9)) < (0, 11):
    raise Exception("Incompatible Kaitai Struct Python API: 0.11 or later is required, but you have %s" % (kaitaistruct.__version__))

import vlq_base128_be
class Bitmessage(ReadWriteKaitaiStruct):

    class ObjectTypeEnum(IntEnum):
        getpubkey = 0
        pubkey = 1
        msg = 2
        broadcast = 3
    def __init__(self, _io=None, _parent=None, _root=None):
        self._io = _io
        self._parent = _parent
        self._root = _root if _root else self

    def _read(self):
        self.message = Bitmessage.Message(self._io, self, self._root)
        self.message._read()


    def _fetch_instances(self):
        pass
        self.message._fetch_instances()


    def _write__seq(self, io=None):
        super(Bitmessage, self)._write__seq(io)
        self.message._write__seq(self._io)


    def _check(self):
        pass
        if self.message._root != self._root:
            raise kaitaistruct.ConsistencyError(u"message", self.message._root, self._root)
        if self.message._parent != self:
            raise kaitaistruct.ConsistencyError(u"message", self.message._parent, self)

    class InvVect(ReadWriteKaitaiStruct):
        def __init__(self, _io=None, _parent=None, _root=None):
            self._io = _io
            self._parent = _parent
            self._root = _root

        def _read(self):
            self.hash = self._io.read_bytes(32)


        def _fetch_instances(self):
            pass


        def _write__seq(self, io=None):
            super(Bitmessage.InvVect, self)._write__seq(io)
            self._io.write_bytes(self.hash)


        def _check(self):
            pass
            if (len(self.hash) != 32):
                raise kaitaistruct.ConsistencyError(u"hash", len(self.hash), 32)


    class ObjectPubkey(ReadWriteKaitaiStruct):
        def __init__(self, _io=None, _parent=None, _root=None):
            self._io = _io
            self._parent = _parent
            self._root = _root

        def _read(self):
            _on = self._parent.version.value
            if _on == 2:
                pass
                self.pubkey = Bitmessage.ObjectPubkeyV2(self._io, self, self._root)
                self.pubkey._read()
            elif _on == 3:
                pass
                self.pubkey = Bitmessage.ObjectPubkeyV3(self._io, self, self._root)
                self.pubkey._read()
            elif _on == 4:
                pass
                self.pubkey = Bitmessage.ObjectPubkeyV4(self._io, self, self._root)
                self.pubkey._read()


        def _fetch_instances(self):
            pass
            _on = self._parent.version.value
            if _on == 2:
                pass
                self.pubkey._fetch_instances()
            elif _on == 3:
                pass
                self.pubkey._fetch_instances()
            elif _on == 4:
                pass
                self.pubkey._fetch_instances()


        def _write__seq(self, io=None):
            super(Bitmessage.ObjectPubkey, self)._write__seq(io)
            _on = self._parent.version.value
            if _on == 2:
                pass
                self.pubkey._write__seq(self._io)
            elif _on == 3:
                pass
                self.pubkey._write__seq(self._io)
            elif _on == 4:
                pass
                self.pubkey._write__seq(self._io)


        def _check(self):
            pass
            _on = self._parent.version.value
            if _on == 2:
                pass
                if self.pubkey._root != self._root:
                    raise kaitaistruct.ConsistencyError(u"pubkey", self.pubkey._root, self._root)
                if self.pubkey._parent != self:
                    raise kaitaistruct.ConsistencyError(u"pubkey", self.pubkey._parent, self)
            elif _on == 3:
                pass
                if self.pubkey._root != self._root:
                    raise kaitaistruct.ConsistencyError(u"pubkey", self.pubkey._root, self._root)
                if self.pubkey._parent != self:
                    raise kaitaistruct.ConsistencyError(u"pubkey", self.pubkey._parent, self)
            elif _on == 4:
                pass
                if self.pubkey._root != self._root:
                    raise kaitaistruct.ConsistencyError(u"pubkey", self.pubkey._root, self._root)
                if self.pubkey._parent != self:
                    raise kaitaistruct.ConsistencyError(u"pubkey", self.pubkey._parent, self)


    class ObjectGetpubkey(ReadWriteKaitaiStruct):
        def __init__(self, _io=None, _parent=None, _root=None):
            self._io = _io
            self._parent = _parent
            self._root = _root

        def _read(self):
            self.ripe = self._io.read_bytes(20)
            self.tag = self._io.read_bytes(32)


        def _fetch_instances(self):
            pass


        def _write__seq(self, io=None):
            super(Bitmessage.ObjectGetpubkey, self)._write__seq(io)
            self._io.write_bytes(self.ripe)
            self._io.write_bytes(self.tag)


        def _check(self):
            pass
            if (len(self.ripe) != 20):
                raise kaitaistruct.ConsistencyError(u"ripe", len(self.ripe), 20)
            if (len(self.tag) != 32):
                raise kaitaistruct.ConsistencyError(u"tag", len(self.tag), 32)


    class NotPrefixedNetAddr(ReadWriteKaitaiStruct):
        def __init__(self, _io=None, _parent=None, _root=None):
            self._io = _io
            self._parent = _parent
            self._root = _root

        def _read(self):
            self.services = self._io.read_u8be()
            self.ip = self._io.read_bytes(16)
            self.port = self._io.read_u2be()


        def _fetch_instances(self):
            pass


        def _write__seq(self, io=None):
            super(Bitmessage.NotPrefixedNetAddr, self)._write__seq(io)
            self._io.write_u8be(self.services)
            self._io.write_bytes(self.ip)
            self._io.write_u2be(self.port)


        def _check(self):
            pass
            if (len(self.ip) != 16):
                raise kaitaistruct.ConsistencyError(u"ip", len(self.ip), 16)


    class ObjectPubkeyV2(ReadWriteKaitaiStruct):
        def __init__(self, _io=None, _parent=None, _root=None):
            self._io = _io
            self._parent = _parent
            self._root = _root

        def _read(self):
            self.behavior_bitfield = self._io.read_u4be()
            self.public_signing_key = self._io.read_bytes(64)
            self.public_encryption_key = self._io.read_bytes(64)


        def _fetch_instances(self):
            pass


        def _write__seq(self, io=None):
            super(Bitmessage.ObjectPubkeyV2, self)._write__seq(io)
            self._io.write_u4be(self.behavior_bitfield)
            self._io.write_bytes(self.public_signing_key)
            self._io.write_bytes(self.public_encryption_key)


        def _check(self):
            pass
            if (len(self.public_signing_key) != 64):
                raise kaitaistruct.ConsistencyError(u"public_signing_key", len(self.public_signing_key), 64)
            if (len(self.public_encryption_key) != 64):
                raise kaitaistruct.ConsistencyError(u"public_encryption_key", len(self.public_encryption_key), 64)


    class ObjectBroadcast(ReadWriteKaitaiStruct):
        def __init__(self, _io=None, _parent=None, _root=None):
            self._io = _io
            self._parent = _parent
            self._root = _root

        def _read(self):
            self.encrypted_broadcast = self._io.read_bytes_full()


        def _fetch_instances(self):
            pass


        def _write__seq(self, io=None):
            super(Bitmessage.ObjectBroadcast, self)._write__seq(io)
            self._io.write_bytes(self.encrypted_broadcast)
            if not self._io.is_eof():
                raise kaitaistruct.ConsistencyError(u"encrypted_broadcast", self._io.size() - self._io.pos(), 0)


        def _check(self):
            pass


    class MessageGetdataType(ReadWriteKaitaiStruct):
        def __init__(self, _io=None, _parent=None, _root=None):
            self._io = _io
            self._parent = _parent
            self._root = _root

        def _read(self):
            self.count = vlq_base128_be.VlqBase128Be(self._io)
            self.count._read()
            self.inventory = []
            for i in range(self.count.value):
                _t_inventory = Bitmessage.InvVect(self._io, self, self._root)
                _t_inventory._read()
                self.inventory.append(_t_inventory)



        def _fetch_instances(self):
            pass
            self.count._fetch_instances()
            for i in range(len(self.inventory)):
                pass
                self.inventory[i]._fetch_instances()



        def _write__seq(self, io=None):
            super(Bitmessage.MessageGetdataType, self)._write__seq(io)
            self.count._write__seq(self._io)
            for i in range(len(self.inventory)):
                pass
                self.inventory[i]._write__seq(self._io)



        def _check(self):
            pass
            if (len(self.inventory) != self.count.value):
                raise kaitaistruct.ConsistencyError(u"inventory", len(self.inventory), self.count.value)
            for i in range(len(self.inventory)):
                pass
                if self.inventory[i]._root != self._root:
                    raise kaitaistruct.ConsistencyError(u"inventory", self.inventory[i]._root, self._root)
                if self.inventory[i]._parent != self:
                    raise kaitaistruct.ConsistencyError(u"inventory", self.inventory[i]._parent, self)



    class MessageVerackType(ReadWriteKaitaiStruct):
        def __init__(self, _io=None, _parent=None, _root=None):
            self._io = _io
            self._parent = _parent
            self._root = _root

        def _read(self):
            pass


        def _fetch_instances(self):
            pass


        def _write__seq(self, io=None):
            super(Bitmessage.MessageVerackType, self)._write__seq(io)


        def _check(self):
            pass


    class VarStr(ReadWriteKaitaiStruct):
        def __init__(self, _io=None, _parent=None, _root=None):
            self._io = _io
            self._parent = _parent
            self._root = _root

        def _read(self):
            self.len = vlq_base128_be.VlqBase128Be(self._io)
            self.len._read()
            self.value = (self._io.read_bytes(self.len.value)).decode("ASCII")


        def _fetch_instances(self):
            pass
            self.len._fetch_instances()


        def _write__seq(self, io=None):
            super(Bitmessage.VarStr, self)._write__seq(io)
            self.len._write__seq(self._io)
            self._io.write_bytes((self.value).encode(u"ASCII"))


        def _check(self):
            pass
            if (len((self.value).encode(u"ASCII")) != self.len.value):
                raise kaitaistruct.ConsistencyError(u"value", len((self.value).encode(u"ASCII")), self.len.value)


    class MessageVersionType(ReadWriteKaitaiStruct):
        def __init__(self, _io=None, _parent=None, _root=None):
            self._io = _io
            self._parent = _parent
            self._root = _root

        def _read(self):
            self.version = self._io.read_s4be()
            self.services = self._io.read_u8be()
            self.timestamp = self._io.read_s8be()
            self.addr_recv = Bitmessage.NotPrefixedNetAddr(self._io, self, self._root)
            self.addr_recv._read()
            self.addr_from = Bitmessage.NotPrefixedNetAddr(self._io, self, self._root)
            self.addr_from._read()
            self.nonce = self._io.read_u8be()
            self.user_agent = Bitmessage.VarStr(self._io, self, self._root)
            self.user_agent._read()
            self.stream_numbers = Bitmessage.VarIntList(self._io, self, self._root)
            self.stream_numbers._read()


        def _fetch_instances(self):
            pass
            self.addr_recv._fetch_instances()
            self.addr_from._fetch_instances()
            self.user_agent._fetch_instances()
            self.stream_numbers._fetch_instances()


        def _write__seq(self, io=None):
            super(Bitmessage.MessageVersionType, self)._write__seq(io)
            self._io.write_s4be(self.version)
            self._io.write_u8be(self.services)
            self._io.write_s8be(self.timestamp)
            self.addr_recv._write__seq(self._io)
            self.addr_from._write__seq(self._io)
            self._io.write_u8be(self.nonce)
            self.user_agent._write__seq(self._io)
            self.stream_numbers._write__seq(self._io)


        def _check(self):
            pass
            if self.addr_recv._root != self._root:
                raise kaitaistruct.ConsistencyError(u"addr_recv", self.addr_recv._root, self._root)
            if self.addr_recv._parent != self:
                raise kaitaistruct.ConsistencyError(u"addr_recv", self.addr_recv._parent, self)
            if self.addr_from._root != self._root:
                raise kaitaistruct.ConsistencyError(u"addr_from", self.addr_from._root, self._root)
            if self.addr_from._parent != self:
                raise kaitaistruct.ConsistencyError(u"addr_from", self.addr_from._parent, self)
            if self.user_agent._root != self._root:
                raise kaitaistruct.ConsistencyError(u"user_agent", self.user_agent._root, self._root)
            if self.user_agent._parent != self:
                raise kaitaistruct.ConsistencyError(u"user_agent", self.user_agent._parent, self)
            if self.stream_numbers._root != self._root:
                raise kaitaistruct.ConsistencyError(u"stream_numbers", self.stream_numbers._root, self._root)
            if self.stream_numbers._parent != self:
                raise kaitaistruct.ConsistencyError(u"stream_numbers", self.stream_numbers._parent, self)


    class ObjectMsg(ReadWriteKaitaiStruct):
        def __init__(self, _io=None, _parent=None, _root=None):
            self._io = _io
            self._parent = _parent
            self._root = _root

        def _read(self):
            self.encrypted_msg = self._io.read_bytes_full()


        def _fetch_instances(self):
            pass


        def _write__seq(self, io=None):
            super(Bitmessage.ObjectMsg, self)._write__seq(io)
            self._io.write_bytes(self.encrypted_msg)
            if not self._io.is_eof():
                raise kaitaistruct.ConsistencyError(u"encrypted_msg", self._io.size() - self._io.pos(), 0)


        def _check(self):
            pass


    class VarIntList(ReadWriteKaitaiStruct):
        def __init__(self, _io=None, _parent=None, _root=None):
            self._io = _io
            self._parent = _parent
            self._root = _root

        def _read(self):
            self.len = vlq_base128_be.VlqBase128Be(self._io)
            self.len._read()
            self.value = []
            for i in range(self.len.value):
                _t_value = vlq_base128_be.VlqBase128Be(self._io)
                _t_value._read()
                self.value.append(_t_value)



        def _fetch_instances(self):
            pass
            self.len._fetch_instances()
            for i in range(len(self.value)):
                pass
                self.value[i]._fetch_instances()



        def _write__seq(self, io=None):
            super(Bitmessage.VarIntList, self)._write__seq(io)
            self.len._write__seq(self._io)
            for i in range(len(self.value)):
                pass
                self.value[i]._write__seq(self._io)



        def _check(self):
            pass
            if (len(self.value) != self.len.value):
                raise kaitaistruct.ConsistencyError(u"value", len(self.value), self.len.value)
            for i in range(len(self.value)):
                pass



    class ObjectPubkeyV4(ReadWriteKaitaiStruct):
        def __init__(self, _io=None, _parent=None, _root=None):
            self._io = _io
            self._parent = _parent
            self._root = _root

        def _read(self):
            self.tag = self._io.read_bytes(64)
            self.encrypted = self._io.read_bytes_full()


        def _fetch_instances(self):
            pass


        def _write__seq(self, io=None):
            super(Bitmessage.ObjectPubkeyV4, self)._write__seq(io)
            self._io.write_bytes(self.tag)
            self._io.write_bytes(self.encrypted)
            if not self._io.is_eof():
                raise kaitaistruct.ConsistencyError(u"encrypted", self._io.size() - self._io.pos(), 0)


        def _check(self):
            pass
            if (len(self.tag) != 64):
                raise kaitaistruct.ConsistencyError(u"tag", len(self.tag), 64)


    class NetAddr(ReadWriteKaitaiStruct):
        def __init__(self, _io=None, _parent=None, _root=None):
            self._io = _io
            self._parent = _parent
            self._root = _root

        def _read(self):
            self.time = self._io.read_u8be()
            self.stream = self._io.read_u4be()
            self.payload = Bitmessage.NotPrefixedNetAddr(self._io, self, self._root)
            self.payload._read()


        def _fetch_instances(self):
            pass
            self.payload._fetch_instances()


        def _write__seq(self, io=None):
            super(Bitmessage.NetAddr, self)._write__seq(io)
            self._io.write_u8be(self.time)
            self._io.write_u4be(self.stream)
            self.payload._write__seq(self._io)


        def _check(self):
            pass
            if self.payload._root != self._root:
                raise kaitaistruct.ConsistencyError(u"payload", self.payload._root, self._root)
            if self.payload._parent != self:
                raise kaitaistruct.ConsistencyError(u"payload", self.payload._parent, self)


    class Message(ReadWriteKaitaiStruct):
        def __init__(self, _io=None, _parent=None, _root=None):
            self._io = _io
            self._parent = _parent
            self._root = _root

        def _read(self):
            self.header = Bitmessage.MessageHeader(self._io, self, self._root)
            self.header._read()
            _on = self.header.command
            if _on == u"object":
                pass
                self.payload = Bitmessage.MessageObjectType(self._io, self, self._root)
                self.payload._read()
            elif _on == u"addr":
                pass
                self.payload = Bitmessage.MessageAddrType(self._io, self, self._root)
                self.payload._read()
            elif _on == u"getdata":
                pass
                self.payload = Bitmessage.MessageGetdataType(self._io, self, self._root)
                self.payload._read()
            elif _on == u"version":
                pass
                self.payload = Bitmessage.MessageVersionType(self._io, self, self._root)
                self.payload._read()
            elif _on == u"inv":
                pass
                self.payload = Bitmessage.MessageInvType(self._io, self, self._root)
                self.payload._read()
            elif _on == u"verack":
                pass
                self.payload = Bitmessage.MessageVerackType(self._io, self, self._root)
                self.payload._read()


        def _fetch_instances(self):
            pass
            self.header._fetch_instances()
            _on = self.header.command
            if _on == u"object":
                pass
                self.payload._fetch_instances()
            elif _on == u"addr":
                pass
                self.payload._fetch_instances()
            elif _on == u"getdata":
                pass
                self.payload._fetch_instances()
            elif _on == u"version":
                pass
                self.payload._fetch_instances()
            elif _on == u"inv":
                pass
                self.payload._fetch_instances()
            elif _on == u"verack":
                pass
                self.payload._fetch_instances()


        def _write__seq(self, io=None):
            super(Bitmessage.Message, self)._write__seq(io)
            self.header._write__seq(self._io)
            _on = self.header.command
            if _on == u"object":
                pass
                self.payload._write__seq(self._io)
            elif _on == u"addr":
                pass
                self.payload._write__seq(self._io)
            elif _on == u"getdata":
                pass
                self.payload._write__seq(self._io)
            elif _on == u"version":
                pass
                self.payload._write__seq(self._io)
            elif _on == u"inv":
                pass
                self.payload._write__seq(self._io)
            elif _on == u"verack":
                pass
                self.payload._write__seq(self._io)


        def _check(self):
            pass
            if self.header._root != self._root:
                raise kaitaistruct.ConsistencyError(u"header", self.header._root, self._root)
            if self.header._parent != self:
                raise kaitaistruct.ConsistencyError(u"header", self.header._parent, self)
            _on = self.header.command
            if _on == u"object":
                pass
                if self.payload._root != self._root:
                    raise kaitaistruct.ConsistencyError(u"payload", self.payload._root, self._root)
                if self.payload._parent != self:
                    raise kaitaistruct.ConsistencyError(u"payload", self.payload._parent, self)
            elif _on == u"addr":
                pass
                if self.payload._root != self._root:
                    raise kaitaistruct.ConsistencyError(u"payload", self.payload._root, self._root)
                if self.payload._parent != self:
                    raise kaitaistruct.ConsistencyError(u"payload", self.payload._parent, self)
            elif _on == u"getdata":
                pass
                if self.payload._root != self._root:
                    raise kaitaistruct.ConsistencyError(u"payload", self.payload._root, self._root)
                if self.payload._parent != self:
                    raise kaitaistruct.ConsistencyError(u"payload", self.payload._parent, self)
            elif _on == u"version":
                pass
                if self.payload._root != self._root:
                    raise kaitaistruct.ConsistencyError(u"payload", self.payload._root, self._root)
                if self.payload._parent != self:
                    raise kaitaistruct.ConsistencyError(u"payload", self.payload._parent, self)
            elif _on == u"inv":
                pass
                if self.payload._root != self._root:
                    raise kaitaistruct.ConsistencyError(u"payload", self.payload._root, self._root)
                if self.payload._parent != self:
                    raise kaitaistruct.ConsistencyError(u"payload", self.payload._parent, self)
            elif _on == u"verack":
                pass
                if self.payload._root != self._root:
                    raise kaitaistruct.ConsistencyError(u"payload", self.payload._root, self._root)
                if self.payload._parent != self:
                    raise kaitaistruct.ConsistencyError(u"payload", self.payload._parent, self)


    class MessageAddrType(ReadWriteKaitaiStruct):
        def __init__(self, _io=None, _parent=None, _root=None):
            self._io = _io
            self._parent = _parent
            self._root = _root

        def _read(self):
            self.count = vlq_base128_be.VlqBase128Be(self._io)
            self.count._read()
            self.addr_list = []
            for i in range(self.count.value):
                _t_addr_list = Bitmessage.NetAddr(self._io, self, self._root)
                _t_addr_list._read()
                self.addr_list.append(_t_addr_list)



        def _fetch_instances(self):
            pass
            self.count._fetch_instances()
            for i in range(len(self.addr_list)):
                pass
                self.addr_list[i]._fetch_instances()



        def _write__seq(self, io=None):
            super(Bitmessage.MessageAddrType, self)._write__seq(io)
            self.count._write__seq(self._io)
            for i in range(len(self.addr_list)):
                pass
                self.addr_list[i]._write__seq(self._io)



        def _check(self):
            pass
            if (len(self.addr_list) != self.count.value):
                raise kaitaistruct.ConsistencyError(u"addr_list", len(self.addr_list), self.count.value)
            for i in range(len(self.addr_list)):
                pass
                if self.addr_list[i]._root != self._root:
                    raise kaitaistruct.ConsistencyError(u"addr_list", self.addr_list[i]._root, self._root)
                if self.addr_list[i]._parent != self:
                    raise kaitaistruct.ConsistencyError(u"addr_list", self.addr_list[i]._parent, self)



    class MessageInvType(ReadWriteKaitaiStruct):
        def __init__(self, _io=None, _parent=None, _root=None):
            self._io = _io
            self._parent = _parent
            self._root = _root

        def _read(self):
            self.count = vlq_base128_be.VlqBase128Be(self._io)
            self.count._read()
            self.inventory = []
            for i in range(self.count.value):
                _t_inventory = Bitmessage.InvVect(self._io, self, self._root)
                _t_inventory._read()
                self.inventory.append(_t_inventory)



        def _fetch_instances(self):
            pass
            self.count._fetch_instances()
            for i in range(len(self.inventory)):
                pass
                self.inventory[i]._fetch_instances()



        def _write__seq(self, io=None):
            super(Bitmessage.MessageInvType, self)._write__seq(io)
            self.count._write__seq(self._io)
            for i in range(len(self.inventory)):
                pass
                self.inventory[i]._write__seq(self._io)



        def _check(self):
            pass
            if (len(self.inventory) != self.count.value):
                raise kaitaistruct.ConsistencyError(u"inventory", len(self.inventory), self.count.value)
            for i in range(len(self.inventory)):
                pass
                if self.inventory[i]._root != self._root:
                    raise kaitaistruct.ConsistencyError(u"inventory", self.inventory[i]._root, self._root)
                if self.inventory[i]._parent != self:
                    raise kaitaistruct.ConsistencyError(u"inventory", self.inventory[i]._parent, self)



    class MessageObjectType(ReadWriteKaitaiStruct):
        def __init__(self, _io=None, _parent=None, _root=None):
            self._io = _io
            self._parent = _parent
            self._root = _root

        def _read(self):
            self.nonce = self._io.read_u8be()
            self.expires_time = self._io.read_u8be()
            self.object_payload_type = KaitaiStream.resolve_enum(Bitmessage.ObjectTypeEnum, self._io.read_u4be())
            self.version = vlq_base128_be.VlqBase128Be(self._io)
            self.version._read()
            self.stream_number = vlq_base128_be.VlqBase128Be(self._io)
            self.stream_number._read()
            _on = self.object_payload_type
            if _on == Bitmessage.ObjectTypeEnum.getpubkey:
                pass
                self.object_payload = Bitmessage.ObjectGetpubkey(self._io, self, self._root)
                self.object_payload._read()
            elif _on == Bitmessage.ObjectTypeEnum.msg:
                pass
                self.object_payload = Bitmessage.ObjectMsg(self._io, self, self._root)
                self.object_payload._read()
            elif _on == Bitmessage.ObjectTypeEnum.broadcast:
                pass
                self.object_payload = Bitmessage.ObjectBroadcast(self._io, self, self._root)
                self.object_payload._read()
            elif _on == Bitmessage.ObjectTypeEnum.pubkey:
                pass
                self.object_payload = Bitmessage.ObjectPubkey(self._io, self, self._root)
                self.object_payload._read()


        def _fetch_instances(self):
            pass
            self.version._fetch_instances()
            self.stream_number._fetch_instances()
            _on = self.object_payload_type
            if _on == Bitmessage.ObjectTypeEnum.getpubkey:
                pass
                self.object_payload._fetch_instances()
            elif _on == Bitmessage.ObjectTypeEnum.msg:
                pass
                self.object_payload._fetch_instances()
            elif _on == Bitmessage.ObjectTypeEnum.broadcast:
                pass
                self.object_payload._fetch_instances()
            elif _on == Bitmessage.ObjectTypeEnum.pubkey:
                pass
                self.object_payload._fetch_instances()


        def _write__seq(self, io=None):
            super(Bitmessage.MessageObjectType, self)._write__seq(io)
            self._io.write_u8be(self.nonce)
            self._io.write_u8be(self.expires_time)
            self._io.write_u4be(int(self.object_payload_type))
            self.version._write__seq(self._io)
            self.stream_number._write__seq(self._io)
            _on = self.object_payload_type
            if _on == Bitmessage.ObjectTypeEnum.getpubkey:
                pass
                self.object_payload._write__seq(self._io)
            elif _on == Bitmessage.ObjectTypeEnum.msg:
                pass
                self.object_payload._write__seq(self._io)
            elif _on == Bitmessage.ObjectTypeEnum.broadcast:
                pass
                self.object_payload._write__seq(self._io)
            elif _on == Bitmessage.ObjectTypeEnum.pubkey:
                pass
                self.object_payload._write__seq(self._io)


        def _check(self):
            pass
            _on = self.object_payload_type
            if _on == Bitmessage.ObjectTypeEnum.getpubkey:
                pass
                if self.object_payload._root != self._root:
                    raise kaitaistruct.ConsistencyError(u"object_payload", self.object_payload._root, self._root)
                if self.object_payload._parent != self:
                    raise kaitaistruct.ConsistencyError(u"object_payload", self.object_payload._parent, self)
            elif _on == Bitmessage.ObjectTypeEnum.msg:
                pass
                if self.object_payload._root != self._root:
                    raise kaitaistruct.ConsistencyError(u"object_payload", self.object_payload._root, self._root)
                if self.object_payload._parent != self:
                    raise kaitaistruct.ConsistencyError(u"object_payload", self.object_payload._parent, self)
            elif _on == Bitmessage.ObjectTypeEnum.broadcast:
                pass
                if self.object_payload._root != self._root:
                    raise kaitaistruct.ConsistencyError(u"object_payload", self.object_payload._root, self._root)
                if self.object_payload._parent != self:
                    raise kaitaistruct.ConsistencyError(u"object_payload", self.object_payload._parent, self)
            elif _on == Bitmessage.ObjectTypeEnum.pubkey:
                pass
                if self.object_payload._root != self._root:
                    raise kaitaistruct.ConsistencyError(u"object_payload", self.object_payload._root, self._root)
                if self.object_payload._parent != self:
                    raise kaitaistruct.ConsistencyError(u"object_payload", self.object_payload._parent, self)


    class ObjectPubkeyV3(ReadWriteKaitaiStruct):
        def __init__(self, _io=None, _parent=None, _root=None):
            self._io = _io
            self._parent = _parent
            self._root = _root

        def _read(self):
            self.behavior_bitfield = self._io.read_u4be()
            self.public_signing_key = self._io.read_bytes(64)
            self.public_encryption_key = self._io.read_bytes(64)
            self.nonce_trials_per_byte = vlq_base128_be.VlqBase128Be(self._io)
            self.nonce_trials_per_byte._read()
            self.extra_bytes = vlq_base128_be.VlqBase128Be(self._io)
            self.extra_bytes._read()
            self.sig_length = vlq_base128_be.VlqBase128Be(self._io)
            self.sig_length._read()
            self.signature = self._io.read_bytes(self.sig_length.value)


        def _fetch_instances(self):
            pass
            self.nonce_trials_per_byte._fetch_instances()
            self.extra_bytes._fetch_instances()
            self.sig_length._fetch_instances()


        def _write__seq(self, io=None):
            super(Bitmessage.ObjectPubkeyV3, self)._write__seq(io)
            self._io.write_u4be(self.behavior_bitfield)
            self._io.write_bytes(self.public_signing_key)
            self._io.write_bytes(self.public_encryption_key)
            self.nonce_trials_per_byte._write__seq(self._io)
            self.extra_bytes._write__seq(self._io)
            self.sig_length._write__seq(self._io)
            self._io.write_bytes(self.signature)


        def _check(self):
            pass
            if (len(self.public_signing_key) != 64):
                raise kaitaistruct.ConsistencyError(u"public_signing_key", len(self.public_signing_key), 64)
            if (len(self.public_encryption_key) != 64):
                raise kaitaistruct.ConsistencyError(u"public_encryption_key", len(self.public_encryption_key), 64)
            if (len(self.signature) != self.sig_length.value):
                raise kaitaistruct.ConsistencyError(u"signature", len(self.signature), self.sig_length.value)


    class MessageHeader(ReadWriteKaitaiStruct):
        def __init__(self, _io=None, _parent=None, _root=None):
            self._io = _io
            self._parent = _parent
            self._root = _root

        def _read(self):
            self.magic = self._io.read_bytes(4)
            if not (self.magic == b"\xE9\xBE\xB4\xD9"):
                raise kaitaistruct.ValidationNotEqualError(b"\xE9\xBE\xB4\xD9", self.magic, self._io, u"/types/message_header/seq/0")
            self.command = (KaitaiStream.bytes_terminate(self._io.read_bytes(12), 0, False)).decode("ASCII")
            self.length = self._io.read_u4be()
            self.checksum = self._io.read_u4be()


        def _fetch_instances(self):
            pass


        def _write__seq(self, io=None):
            super(Bitmessage.MessageHeader, self)._write__seq(io)
            self._io.write_bytes(self.magic)
            self._io.write_bytes_limit((self.command).encode(u"ASCII"), 12, 0, 0)
            self._io.write_u4be(self.length)
            self._io.write_u4be(self.checksum)


        def _check(self):
            pass
            if (len(self.magic) != 4):
                raise kaitaistruct.ConsistencyError(u"magic", len(self.magic), 4)
            if not (self.magic == b"\xE9\xBE\xB4\xD9"):
                raise kaitaistruct.ValidationNotEqualError(b"\xE9\xBE\xB4\xD9", self.magic, None, u"/types/message_header/seq/0")
            if (len((self.command).encode(u"ASCII")) > 12):
                raise kaitaistruct.ConsistencyError(u"command", len((self.command).encode(u"ASCII")), 12)
            if (KaitaiStream.byte_array_index_of((self.command).encode(u"ASCII"), 0) != -1):
                raise kaitaistruct.ConsistencyError(u"command", KaitaiStream.byte_array_index_of((self.command).encode(u"ASCII"), 0), -1)



