meta:
  id: bitmessage
  title: Bitmessage
  license: CC0-1.0
  endian: be
  imports:
    - vlq_base128_be
seq:
  - id: message
    type: message
types:
  message:
    seq:
    - id: header
      type: message_header
    - id: payload
      type: 
        switch-on: header.command
        cases:
          '"version"': message_version_type
          '"verack"': message_verack_type
          '"addr"': message_addr_type
          '"inv"': message_inv_type
          '"getdata"': message_getdata_type
          '"object"': message_object_type
  var_str:
    seq:
      - id: len
        type: vlq_base128_be
      - id: value
        type: str
        encoding: ASCII
        size: len.value
  var_int_list:
    seq:
      - id: len
        type: vlq_base128_be
      - id: value
        type: vlq_base128_be
        repeat: expr
        repeat-expr: len.value
  inv_vect:
    seq:
    - id: hash
      size: 32
  not_prefixed_net_addr:
    seq:
      - id: services
        type: u8
      - id: ip
        size: 16
      - id: port
        type: u2
  net_addr:
    seq:
      - id: time
        type: u8
      - id: stream
        type: u4
      - id: payload
        type: not_prefixed_net_addr
  message_header:
    seq:
      - id: magic
        contents: [0xE9, 0xBE, 0xB4, 0xD9]
      - id: command
        type: str
        encoding: ASCII
        size: 12
        terminator: 0
      - id: length
        type: u4
      - id: checksum
        type: u4
  message_version_type:
    seq:
      - id: version
        type: s4
      - id: services
        type: u8
      - id: timestamp
        type: s8
      - id: addr_recv
        type: not_prefixed_net_addr
      - id: addr_from
        type: not_prefixed_net_addr
      - id: nonce
        type: u8
      - id: user_agent
        type: var_str
      - id: stream_numbers
        type: var_int_list
  message_verack_type:
    seq: []
  message_addr_type:
    seq:
    - id: count
      type: vlq_base128_be
    - id: addr_list
      type: net_addr
      repeat: expr
      repeat-expr: count.value
  message_inv_type:
    seq:
    - id: count
      type: vlq_base128_be
    - id: inventory
      type: inv_vect
      repeat: expr
      repeat-expr: count.value
  message_getdata_type:
    seq:
    - id: count
      type: vlq_base128_be
    - id: inventory
      type: inv_vect
      repeat: expr
      repeat-expr: count.value
  message_object_type:
    seq:
      - id: nonce
        type: u8
      - id: expires_time
        -orig-id: expiresTime
        type: u8
      - id: object_payload_type
        -orig-id: objectType
        type: u4
        enum: object_type_enum
      - id: version
        type: vlq_base128_be
      - id: stream_number
        type: vlq_base128_be
      - id: object_payload
        type:
          switch-on: object_payload_type
          cases:
            object_type_enum::getpubkey: object_getpubkey
            object_type_enum::msg: object_msg
            object_type_enum::broadcast: object_broadcast
            object_type_enum::pubkey: object_pubkey
  object_getpubkey:
    seq:
      - id: ripe
        size: 20
      - id: tag
        size: 32
  object_pubkey:
    seq:
    - id: pubkey
      type:
        switch-on: _parent.version.value
        cases:
          2: object_pubkey_v2
          3: object_pubkey_v3
          4: object_pubkey_v4
  object_pubkey_v2:
    seq:
    - id: behavior_bitfield
      type: u4
    - id: public_signing_key
      size: 64
    - id: public_encryption_key
      size: 64
  object_pubkey_v3:
    seq:
    - id: behavior_bitfield
      type: u4
    - id: public_signing_key
      size: 64
    - id: public_encryption_key
      size: 64
    - id: nonce_trials_per_byte
      type: vlq_base128_be
    - id: extra_bytes
      type: vlq_base128_be
    - id: sig_length
      type: vlq_base128_be
    - id: signature
      size: sig_length.value
  object_pubkey_v4:
    seq:
    - id: tag
      size: 64
    - id: encrypted
      size-eos: true
  object_msg:
    seq:
      - id: encrypted_msg
        size-eos: true
  object_broadcast:
    seq:
      - id: encrypted_broadcast
        size-eos: true
enums:
  object_type_enum:
    0: getpubkey
    1: pubkey
    2: msg
    3: broadcast